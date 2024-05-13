/*
Consulta exclui todas as linhas da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" com a data, na qual, o colaborador se 
encontra de férias. Essa tabela armazena os dias uteis do mês em que cada colaborador estava ativo no ponto de atendimento. 
Ela, por sua vez, é usada como base para o cálculo de metas indivíduais.
By: Pâmella
*/

SET periodo = '%CAMPANHA MAI/24%';

/*Exclusão dos registros da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" 
que compreende o período de férias do colaborador, ou seja, os dias que ele não se encontra ativo no ponto de atendimento.*/
DELETE FROM sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util
USING(    
    WITH 
    /*Retorna o registro da solicitação de férias mais atual do colaborador.*/
    maximo_ferias AS
    (  
        SELECT 
            tabela.campanha
            ,UPPER(RTRIM(LTRIM(tabela.matricula))) AS matricula
            ,MAX(tabela.dta_solicitacao) AS dta_solicitacao
        FROM sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos AS tabela
        
        WHERE 
            tabela.campanha LIKE $periodo
            AND tabela.nom_pto_transf IS NULL
            AND tabela.dta_saida IS NOT NULL 
            AND tabela.dta_retorno IS NOT NULL 
            
        GROUP BY ALL
    )
    
    /*Retorna os demais campos do registro de solicitação de férias mais atual do colaborador, converte os tipos de data para
    o formato DATE yyyy-mm-dd e filtra os outliers.*/
    ,ferias AS
    (
        SELECT 
            tabela.campanha
            ,UPPER(RTRIM(LTRIM(tabela.matricula))) AS matricula
            ,TO_DATE(tabela.dta_saida,'DD/MM/YYYY') AS dta_saida -- Convertendo datas de 'dd/MM/yyyy' para DATE yyyy-mm-dd
            ,TO_DATE(tabela.dta_retorno,'DD/MM/YYYY') AS dta_retorno -- Convertendo datas de 'dd/MM/yyyy' para DATE yyyy-mm-dd
            ,tabela.dta_solicitacao
            ,DATEDIFF(DAY,TO_DATE(tabela.dta_saida,'DD/MM/YYYY'),TO_DATE(tabela.dta_retorno,'DD/MM/YYYY')) AS qnt_dias
        
        FROM sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos AS tabela
        
        INNER JOIN maximo_ferias
            ON tabela.campanha = maximo_ferias.campanha
            AND UPPER(RTRIM(LTRIM(tabela.matricula))) = maximo_ferias.matricula
            AND tabela.dta_solicitacao = maximo_ferias.dta_solicitacao

        WHERE
            DATEDIFF(DAY,TO_DATE(tabela.dta_saida,'DD/MM/YYYY'),TO_DATE(tabela.dta_retorno,'DD/MM/YYYY')) >= 0
            AND DATEDIFF(DAY,TO_DATE(tabela.dta_saida,'DD/MM/YYYY'),TO_DATE(tabela.dta_retorno,'DD/MM/YYYY')) <= 100
    )
    
    /*Retorna os dados dos colaboradores que podem constar na tabela 
    "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util", ou seja, apenas gerente de contas e 
    produtos e agentes comerciais. Isso porque, apenas esses cargos possuem metas individuais.*/
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
          AND (empregado.idt_emp IN ('2', '27'))
          AND (cargo_basico.idt_cgo_bse IN (2764, 2067, 2344, 3133, 3134))
        ) -- gerente de agencia nao entra na tabela de dias uteis. Gerente de contas e produtos e agentes comerciais apenas que entram na tabela de dias uteis.
    )
    
    /*Retorna os reigstros da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" nos 
    quais o colaborador se encontra de férias, retirando da consulta as solicitações de colaboradores que não se enquadram nos
    cargos de gerente de contas e produtos e agentes comerciais.*/
    ,dias_uteis AS
    (
        SELECT 
            ferias.campanha
            ,CONCAT(int_participantes_dia_util.matricula,'-',
                    int_participantes_dia_util.num_dnd,'-',
                    int_participantes_dia_util.data_movimento) AS chave
            ,ferias.matricula AS matricula_ferias
            ,int_participantes_dia_util.matricula AS matricula_dia_util
            ,int_participantes_dia_util.num_dnd
            ,ferias.dta_saida
            ,ferias.dta_retorno
            ,ferias.qnt_dias
            ,int_participantes_dia_util.data_movimento

            ,empregado.idt_emp AS numero_empresa
            ,empregado.num_mat_epg AS matricula_empregado
            ,empregado.idt_cgo AS numero_cargo
            ,empregado.dta_ads
            ,empregado.dta_dms
            ,empregado.num_cen_cst AS centro_custo
            ,empregado.nom_cgo AS nome_cargo
            ,empregado.nom_cgo_bse AS nome_cargo_base
        
        FROM ferias
    
        INNER JOIN empregado
            ON empregado.num_mat_epg = CAST(RIGHT(ferias.matricula,5) AS INT)
      
        LEFT JOIN sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util AS int_participantes_dia_util
            ON int_participantes_dia_util.matricula = ferias.matricula
            AND int_participantes_dia_util.data_movimento >= ferias.dta_saida
            AND int_participantes_dia_util.data_movimento < ferias.dta_retorno
        
        WHERE int_participantes_dia_util.matricula IS NOT NULL -- garante que apenas os casos de férias venham na consulta, inserções não contam aqui.
    )

    /*Retorna a coluna "chave" dos registros aptos a serem excluídos da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util"*/
    ,dados_deletados AS
    (
        SELECT DISTINCT dias_uteis.chave FROM dias_uteis

        INNER JOIN sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util AS int_participantes_dia_util
            ON CONCAT(int_participantes_dia_util.matricula,'-',
                     int_participantes_dia_util.num_dnd,'-',
                     int_participantes_dia_util.data_movimento) = dias_uteis.chave
    )
    
    SELECT * FROM dados_deletados
) AS sub

WHERE CONCAT(sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util.matricula,'-',
            sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util.num_dnd,'-',
            sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util.data_movimento) = sub.chave
