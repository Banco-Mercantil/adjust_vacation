# Ajuste de Férias:

O real objetivo deste trabalho é demonstrar, passo a passo, como realizar os ajustes do cálculo das metas individuais de acordo com a quantidade de colaboradores ativos no ponto de atendimento do banco Mercantil.

As metas do ponto de atendimento são informadas, via planilha, no início de cada mês. Essas metas permanecem fixas no decorrer do mês vigente e as metas individuais de cada colaborador é baseada na meta do ponto de antendimento dividida pela quantidade de colaboradores que estarão atuando neste período.

Portanto, a meta do ponto de atendimento é dividida pela quantidade de dias úteis no mês, obtendo a meta diária do ponto de atendimento. Este valor é dividido pela quantidade de colaboradores atuando no dia, tendo-se a meta individual diária do colaborador. Esse valor é sumarizado o número de dias úteis do mês para se ter a meta individual mensal do colaborador. 

![image](https://github.com/Banco-Mercantil/adjust_vacation/assets/88452990/5a8dbb72-5650-4002-b171-619e6c4500e4)


# Inicializando o ajuste:

O controle de agentes ativos por ponto de atendimento é armazenado na tabela 'sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util'. Essa possui todos os dias úteis do mês vigente para cada matrícula ativa. O trabalho a ser realizado aqui é atualizar esta tabela com as devidas correções de férias, afastamentos e transferências.

As informações de férias, afastamentos e transferências é nos passada através do formulário de solicitações. Os responsáveis encaminham uma resposta ao documento informando o tipo e as respectivas datas naas quais o colaborador estará indisponível no ponto de atendimento.


### Férias ou Afastamentos:


### Transferência de Agencia:


1 - acessar [formulário de férias](https://docs.google.com/forms/d/132G94v3b3_ARW8Av-g0MYTq718l9n01_tJnyntrgnvk/edit#responses)

2 - tratar excel

4 - mudar nome para int_forms_ferias_afastamentos salvar como csv

copiar arquivo para a pasta : K:\GEC\2024\04. Dados\0_Snowflake\1_Campanhas\dbt_marts_incrementais_campanhas\seeds

abrir projeto no vs code

adicionar o profile do arquivo no profile do seu usuario, salvar e abrir projeto novamente.

substituir o cabeçalho para: DTA_SOLICITACAO,E_MAIL,MATRICULA,CAMPANHA,COLAB_PROMOVIDO,NOM_PTO_TRANSF,DTA_SAIDA,DTA_RETORNO

trocar ; para ,

salvar arquivo

rodar o comando dbt seed --select "nome_arquivo" (dbt seed --select "country_codes")

VERIFICAR NO SNOWFLAKE SE A TABELA FOI ATUALIZADA SELECT * FROM SDX_EXCELENCIA_COMERCIAL.CAMP_INCENTIVO__MARTS_AUXILIARES.INT_FORMS_FERIAS_AFASTAMENTOS
ORDER BY DTA_SOLICITACAO DESC

migrar atualização para o diretorio da AWS: conectar ao SSH

dar o camando pull para atualizar o repositorio da nuvem em sua maquina

ir para o diretorio /home/pfernandes/MB.AWS.BIZ.GEC/1_Campanhas/dbt_marts_incrementais_campanhas e substituir o arquivo

dar o ./build_push_dev.sh

executar o commit

verificar a confirmação no devops

# corrigir a tabela de participantes de dia util e dar um truncate nas metas individuais:











3 - int_metas__individuais



