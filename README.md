# Ajuste de Férias:

O real objetivo deste trabalho é demonstrar, passo a passo, como realizar os ajustes do cálculo das metas individuais de acordo com a quantidade de colaboradores ativos no ponto de atendimento do banco Mercantil.

As metas do ponto de atendimento são informadas, via planilha, no início de cada mês. Essas metas permanecem fixas no decorrer do mês vigente e as metas individuais de cada colaborador é baseada na meta do ponto de antendimento dividida pela quantidade de colaboradores que estarão atuando neste período.

Portanto, a meta do ponto de atendimento é dividida pela quantidade de dias úteis no mês, obtendo a meta diária do ponto de atendimento. Este valor é dividido pela quantidade de colaboradores atuando no dia, tendo-se a meta individual diária do colaborador. Esse valor é sumarizado o número de dias úteis do mês para se ter a meta individual mensal do colaborador. 

![image](https://github.com/Banco-Mercantil/adjust_vacation/assets/88452990/5a8dbb72-5650-4002-b171-619e6c4500e4)


## 🔨 Ferramentas Necessárias:

Para iniciar este projeto será necessário a instalação das seguintes ferramentas:

- [Visual Studio Code](https://code.visualstudio.com/download)
- Excel
  

## Inicializando o ajuste:

O controle de agentes ativos por ponto de atendimento é armazenado na tabela *sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util*. Essa possui todos os dias úteis do mês vigente para cada matrícula ativa. O trabalho a ser realizado aqui é atualizar esta tabela com as devidas correções de férias, afastamentos e transferências.

As informações de férias, afastamentos e transferências é nos passada através do formulário de solicitações. Os responsáveis encaminham uma resposta ao documento informando o tipo e as respectivas datas naas quais o colaborador estará indisponível no ponto de atendimento.


### Formulário:

O primeiro passo envolve uma tratativa do formulário para que este possa ser compilado devidamente. Para acessá-lo, basta clicar no seguinte link e você será redirecionado para sua página. 

  * [Formulário](https://docs.google.com/forms/d/132G94v3b3_ARW8Av-g0MYTq718l9n01_tJnyntrgnvk/edit#responses)

Já na página, você poderá ter acesso ás respostas dos responsáveis de cada ponto de atendimento com suas respectivas solicitações. Clicando em *Link para o app Planilhas* o arquivo será baixado para sua máquina.

O primeiro tratamento a se fazer é eliminar todas as respostas das campanhas anteriores, deixando apenas os novos registros da campanha vigente. Faça isso, filtrando a coluna **campanha** com todos os registros com excessão da camapanha do mês vigente. Posteriormente, exclua todas as linhas. Limpe o filtro e agora você terá apenas as solicitações do mês. 

Em seguida, é necessário ajustar a coluna de **matrícula**. Este campo pode conter valores com espaços, caracteres em minúsculos e a mais. Padronize este campo removendo espaços em branco, tanto a esquerda quanto a direita, deixando os caracteres em maiúsculo e com o tamanho igual a 7. Registros com tamanhos menores não deverão ser considerados.  

O próximo tratamento será uma verificação nas solicitações de transferência. Para esse tipo de solicitação, os campos referentes a data deverão permanecer em branco. Execute um filtro na coluna onde o ponto de atendimento é preenchido, filtre todos os valores diferentes de vazio. Estas são as solicitações de transferência. Para esses casos, exclua todos os valores das colunas de data, deixando-os em branco. 

Se tratando dos campos de datas, certifique-se que o formato do campo seja equivalente ao exemplo a seguir:

``
Exemplo de formato: 01/01/2024
``

Ao salvar o documento, altere seu nome para ``int_forms_ferias_afastamentos`` e o salve em formato ``.csv``, garantindo que ele possa ser interpretado pelo código e transformado em uma tabela no banco de dados. Feito isso, copie o arquivo, cole-o na pasta: ``K:\GEC\2024\04. Dados\0_Snowflake\1_Campanhas\dbt_marts_incrementais_campanhas\seeds`` e abra o projeto ``dbt_marts_incrementais_campanhas`` no **Visual Studio Code**.


## Arquivo .CSV:

Feito isso, caso seja a primeira vez a se executar este projeto em sua máquina, será necessário configurar o arquivo ``profiles.yml``. Este arquivo se encontra no diretório ``C:\Users\XXXXXX\.dbt``. Copie o código contido no arquivo ``profile.yml`` do projeto ``dbt_marts_incrementais_campanhas`` e adicione-o no arquivo ``profiles.yml`` da sua máquina. Salve o arquivo e abra o projeto novamente. Caso não seja a primeira vez, ignore a etapa anterior e siga para os próximos passos.

Abra o arquivo ``int_forms_ferias_afastamentos.csv`` no **VS Code**, substitua o cabeçalho do arquivo, ou seja, a primeira linha, para: 

``DTA_SOLICITACAO,E_MAIL,MATRICULA,CAMPANHA,COLAB_PROMOVIDO,NOM_PTO_TRANSF,DTA_SAIDA,DTA_RETORNO``

Agora iremos substituir o ponto e vírgula (;) por apenas vígula (,). É possível fazer isso com o atalho ``Ctrl + f``. Um box será aberto no canto superior, clique na seta que antecede o box de escrita. Um novo box irá aparecer. No primeiro, digite o valor no qual deseja buscar para substituir, no caso, o ponto e vírgula (;). No segundo, digite o valor o qual você deseja que seja o substituto, no caso, a vírgula (,). Salve o arquivo.


## Projeto:


Tratado o arquivo ``.csv``, iremos migrar os registros da planilha para o nosso *data warehouse*. O comando ``dbt seed`` irá carregar os arquivos ``.csv`` localizados no diretório ``seed-paths`` do projeto dbt ``dbt_marts_incrementais_campanhas``. Logo, abra o terminal do **VS Code** e execute o seguinte trecho de código:

``
dbt seed --select "int_forms_ferias_afastamentos"
``

Afim de verificar as novas atualizações, basta consultar, no **Snowflake**, a tabela ``SDX_EXCELENCIA_COMERCIAL.CAMP_INCENTIVO__MARTS_AUXILIARES.INT_FORMS_FERIAS_AFASTAMENTOS``. Em um novo *notebook* cole a seguinte query:

``
SELECT * FROM SDX_EXCELENCIA_COMERCIAL.CAMP_INCENTIVO__MARTS_AUXILIARES.INT_FORMS_FERIAS_AFASTAMENTOS
ORDER BY DTA_SOLICITACAO DESC
``

Com os novos registros da campanha vigente na tabela, iremos executar essas alterações no diretório da **AWS**. 

conectar ao SSH

dar o camando pull para atualizar o repositorio da nuvem em sua maquina

ir para o diretorio /home/pfernandes/MB.AWS.BIZ.GEC/1_Campanhas/dbt_marts_incrementais_campanhas e substituir o arquivo

dar o ./build_push_dev.sh

executar o commit

verificar a confirmação no devops



### Férias ou Afastamentos:


### Transferência de Agencia:





# corrigir a tabela de participantes de dia util e dar um truncate nas metas individuais:











3 - int_metas__individuais



