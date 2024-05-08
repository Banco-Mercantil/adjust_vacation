/*
  Consulta exclui todas as linhas da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" com a data, na qual, o colaborador se 
  encontra de férias. Essa tabela armazena os dias uteis do mês em que cada colaborador estava ativo no ponto de atendimento. Ela, por sua vez, é usada como base para o
  cálculo de metas indivíduais.
  By: Pâmella
*/

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
        tabela.campanha LIKE '%CAMPANHA MAI/24%'
        AND tabela.dta_saida IS NOT NULL 
        AND tabela.dta_retorno IS NOT NULL 
        
    GROUP BY ALL
)

/*Retorna os demais campos do registro de solicitação de férias mais atual do colaborador e converte os tipos de data para o formato DATE yyyy-mm-dd*/
,ferias AS
(
    SELECT 
        tabela.campanha
        ,UPPER(RTRIM(LTRIM(tabela.matricula))) AS matricula
        ,tabela.nom_pto_transf
        ,TO_DATE(tabela.dta_saida,'DD/MM/YYYY') AS dta_saida -- Convertendo datas de 'dd/MM/yyyy' para DATE yyyy-mm-dd
        ,TO_DATE(tabela.dta_retorno,'DD/MM/YYYY') AS dta_retorno -- Convertendo datas de 'dd/MM/yyyy' para DATE yyyy-mm-dd
        ,tabela.dta_solicitacao
    
    FROM sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos AS tabela
    
    INNER JOIN maximo_ferias
        ON tabela.campanha = maximo_ferias.campanha
        AND UPPER(RTRIM(LTRIM(tabela.matricula))) = maximo_ferias.matricula
        AND tabela.dta_solicitacao = maximo_ferias.dta_solicitacao
)

/*Retorna os reigstros da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" nos quais o colaborador se encontra de férias*/
,dias_uteis AS
(
    SELECT 
        ferias.campanha
        ,ferias.matricula AS matricula_ferias
        ,int_participantes_dia_util.matricula AS matricula_dia_util
        ,int_participantes_dia_util.num_dnd
        ,ferias.dta_saida
        ,ferias.dta_retorno
        ,int_participantes_dia_util.data_movimento
    
    FROM ferias
    
    LEFT JOIN sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util AS int_participantes_dia_util
        ON int_participantes_dia_util.matricula = ferias.matricula
        AND int_participantes_dia_util.data_movimento >= ferias.dta_saida
        AND int_participantes_dia_util.data_movimento < ferias.dta_retorno
    
    WHERE int_participantes_dia_util.matricula IS NOT NULL 
    
    ORDER BY
       int_participantes_dia_util.matricula
       ,int_participantes_dia_util.data_movimento
)

/*
  Exclusão dos registros da tabela "sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util" que compreende o período de férias do colaborador, ou
  seja, os dias que ele não se encontra ativo no ponto de atendimento.
*/
SELECT * FROM dias_uteis

DELETE 
FROM sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util AS int_participantes_dia_util
WHERE 
    int_participantes_dia_util.matricula = dias_uteis.matricula_dia_util
    AND int_participantes_dia_util.num_dnd = dias_uteis.num_dnd
    AND int_participantes_dia_util.data_movimento = dias_uteis.data_movimento
