/*
    Consulta atualiza o campo "num_dnd" da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" 
    de acordo com a solicitação de transferência da unidade de atendimento (PA). Essa tabela armazena os dias úteis do mês em que cada 
    colaborador estava ativo no ponto de atendimento. Ela, por sua vez, é usada como base para o cálculo de metas indivíduais.
    By: Pâmella
*/

SET periodo = '%CAMPANHA MAI/24%';

/*Atualização do campo "num_dnd" da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" 
de acordo com a solicitação de sua transferência de ponto de atendimento.*/
UPDATE sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util AS int_participantes_dia_util
SET int_participantes_dia_util.num_dnd = sub.nom_pto_transf
FROM
(
    /*Retorna o registro da solicitação de transferência mais atual do colaborador.*/
    WITH maximo_transferencia AS
    (  
        SELECT 
            tabela.campanha
            ,UPPER(RTRIM(LTRIM(tabela.matricula))) AS matricula
            ,MAX(tabela.dta_solicitacao) AS dta_solicitacao
            
        FROM sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos AS tabela
        
        WHERE 
            tabela.campanha LIKE $periodo
            AND tabela.nom_pto_transf IS NOT NULL
            AND tabela.dta_saida IS NULL 
            AND tabela.dta_retorno IS NULL
        
        GROUP BY ALL
    )
    
    /*Retorna os demais campos do registro de solicitação de transferência mais atual do colaborador e converte o código do ponto de 
    atendimento em inteiro.*/
    ,transferencia AS
    (
        SELECT 
            tabela.campanha
            ,UPPER(RTRIM(LTRIM(tabela.matricula))) AS matricula
            ,CAST(RIGHT(LEFT(LTRIM(tabela.nom_pto_transf), 4), 3) AS INT) AS nom_pto_transf
            ,tabela.dta_solicitacao
        
        FROM sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos AS tabela
        
        INNER JOIN maximo_transferencia
            ON tabela.campanha = maximo_transferencia.campanha
            AND UPPER(RTRIM(LTRIM(tabela.matricula))) = maximo_transferencia.matricula
            AND tabela.dta_solicitacao = maximo_transferencia.dta_solicitacao
    )
    
    /*Retorna os dados dos colaboradores que podem constar na tabela 
    "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util", ou seja, apenas gerente de contas e produtos e 
    agentes comerciais. Isso porque, apenas esses cargos possuem metas individuais.*/
    ,empregado AS
    (
        SELECT
            empregado.idt_emp
            ,empregado.num_mat_epg
            ,empregado.idt_cgo
            ,empregado.dta_ads
            ,empregado.dta_dms
            ,empregado.num_cen_cst
            ,cargo.nom_cgo
            ,cargo_basico.nom_cgo_bse
            
        FROM sdx_excelencia_comercial.sdx_dominios.stg_administrativo_recursos_humanos__empregado AS empregado
    
        LEFT JOIN sdx_excelencia_comercial.sdx_dominios.stg_administrativo_recursos_humanos__cargo  AS cargo
          ON cargo.idt_emp = empregado.idt_emp
          AND cargo.idt_cgo = empregado.idt_cgo
    
        LEFT JOIN sdx_excelencia_comercial.sdx_dominios.stg_administrativo_recursos_humanos__cargo_basico AS cargo_basico 
          ON cargo_basico.idt_cgo_bse = cargo.idt_cgo_bse
    
        WHERE 
        (
            (empregado.num_cen_cst IS NOT NULL)
            AND (empregado.dta_dms IS NULL)
            AND (empregado.idt_emp IN ('2','27'))
            AND (cargo_basico.idt_cgo_bse IN (2764,2067,2344,3133,3134))
        ) -- gerente de agencia nao entra na tabela de dias uteis, gerente de contas e produtos e agentes comerciais apenas que entram na tabela de dias uteis.
    )
    
    /*Retorna os reigstros da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" nos quais o 
    colaborador passou a estar ativo em outro ponto de atendimento, retirando da consulta as solicitações de colaboradores que não se 
    enquadram nos cargos de gerente de contas e produtos e agentes comerciais.*/
    ,dias_uteis AS
    (
        SELECT 
            transferencia.campanha
            ,transferencia.matricula AS matricula_transferecia
            ,int_participantes_dia_util.matricula AS matricula_dia_util
        
            ,transferencia.nom_pto_transf
            ,int_participantes_dia_util.num_dnd
            ,int_participantes_dia_util.data_movimento

            ,empregado.num_mat_epg AS matricula_empregado
            ,empregado.idt_emp AS numero_empresa
            ,empregado.num_cen_cst AS centro_custo
            ,empregado.idt_cgo AS cargo_empregado
            ,empregado.nom_cgo AS nome_cargo
            ,empregado.nom_cgo_bse AS nome_cargo_basico
            
        FROM transferencia
        
        INNER JOIN empregado
            ON empregado.num_mat_epg = CAST(RIGHT(transferencia.matricula,5) AS INT)
      
        LEFT JOIN sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util AS int_participantes_dia_util
            ON int_participantes_dia_util.matricula = transferencia.matricula
            AND int_participantes_dia_util.num_dnd <> transferencia.nom_pto_transf -- garante que apenas as solicitações de transferências venham na consulta
            
        WHERE 
            int_participantes_dia_util.matricula IS NOT NULL -- garante que não venha casos de inserção de colaborador na tabela de dia_util
    )
    
    /*Retorna os dados da subquery "dias_uteis" aptos a serem excluídos da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util"*/
    ,dados_deletados AS
    (
        SELECT dias_uteis.* FROM dias_uteis

        INNER JOIN sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util AS int_participantes_dia_util
            ON int_participantes_dia_util.matricula = dias_uteis.matricula_dia_util
            AND int_participantes_dia_util.data_movimento = dias_uteis.data_movimento
            AND int_participantes_dia_util.num_dnd <> dias_uteis.nom_pto_transf
    )
    SELECT * FROM dias_uteis
) AS sub
  
WHERE 
    int_participantes_dia_util.matricula = sub.matricula_dia_util
    AND int_participantes_dia_util.data_movimento = sub.data_movimento
    AND int_participantes_dia_util.num_dnd <> sub.nom_pto_transf








