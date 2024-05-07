# adjust_vacation

A meta individual do colaborador é distribuido entre a quantidade de trabalhadores do ponto. A meta é calculada por dia e posteriormente dividida entre os colaboradores que estão trabalhando nesta data.
Em caso de férias e transferências 

1 - acessar [formulário de férias](https://docs.google.com/forms/d/132G94v3b3_ARW8Av-g0MYTq718l9n01_tJnyntrgnvk/edit#responses)

2 - tratar excel

4 - mudar nome para int_forms_ferias_afastamentos salvar como csv

copiar arquivo para a pasta : K:\GEC\2024\04. Dados\0_Snowflake\1_Campanhas\dbt_marts_incrementais_campanhas\seeds e K:\GEC\2024\04. Dados\0_Snowflake\1_Campanhas\Ferias Rede

abrir projeto no vs code

substituir o cabeçalho para: DTA_SOLICITACAO,E_MAIL,MATRICULA,CAMPANHA,COLAB_PROMOVIDO,NOM_PTO_TRANSF,DTA_SAIDA,DTA_RETORNO

trocar ; para ,

salvar arquivo

rodar o comando dbt seed --select "nome_arquivo"(dbt seed --select "country_codes")

VERIFICAR NO SNOWFLAKE SE A TABELA FOI ATUALIZADA SELECT * FROM SDX_EXCELENCIA_COMERCIAL.CAMP_INCENTIVO__MARTS_AUXILIARES.INT_FORMS_FERIAS_AFASTAMENTOS
ORDER BY DTA_SOLICITACAO DESC

migrar atualização para o diretorio da AWS: conectar ao SSH

ir para o diretorio /home/pfernandes/MB.AWS.BIZ.GEC/1_Campanhas/dbt_marts_incrementais_campanhas/seeds e substituir o arquivo

dar o buil 

3 - int_metas__individuais



