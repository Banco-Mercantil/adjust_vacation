# Ajuste de Férias e Afastamentos:

O real objetivo deste trabalho é demonstrar, passo a passo, como realizar os ajustes do cálculo das metas individuais de acordo com a quantidade de colaboradores ativos no ponto de atendimento do banco Mercantil.

As metas do ponto de atendimento são informadas, via planilha, no início de cada mês. Essas metas permanecem fixas no decorrer do mês vigente e as metas individuais de cada colaborador é baseada na meta do ponto de antendimento dividida pela quantidade de colaboradores que estarão atuando neste período.

Portanto, a meta do ponto de atendimento é dividida pela quantidade de dias úteis no mês, obtendo a meta diária do ponto de atendimento. Este valor é dividido pela quantidade de colaboradores atuando no dia, tendo-se a meta individual diária do colaborador. Esse valor é sumarizado o número de dias úteis do mês para se ter a meta individual mensal do colaborador. 

![image](https://github.com/Banco-Mercantil/adjust_vacation/assets/88452990/5a8dbb72-5650-4002-b171-619e6c4500e4)


## 🔨 Ferramentas Necessárias:

Para iniciar este projeto será necessário a instalação das seguintes ferramentas:

- [Visual Studio Code](https://code.visualstudio.com/download)
- Snowflake
- DBT
- Excel

  
## 🚀 Inicializando o projeto:

### 1.0 Paralisação da campanha atual:

Inicialmente, para que possamos ajustar os devidos paramêtros, a primeira ação a ser cumprida envolve paralisar a atualização dos pacotes de campanha que estão ativos a fim de que não haja nenhum tipo de competição entre o arquivo atual e o novo arquivo que iremos migrar.

Para tal, acesse o site do *[Airflow](https://airflow.real-dev.n-mercantil.com.br/home)* com seu login e senha. Ao entrar, você verá todas as *DAGs* disponíveis do banco. Esta, por sua vez, é uma coleção de tarefas organizadas que você quer programar e executar a qualquer instante.

Com o site aberto, localize a *DAG* na qual você estará fazendo a atualização do projeto e clique em seu nome. Você será redirecionado para uma nova tela e nela basta pausar a atualização agendada, conforme a imagem abaixo:

![image](https://github.com/Banco-Mercantil/campaign_update/assets/88452990/9eebadbe-8205-41bb-8308-ee214eb7293b)

Feito isso. Podemos dar sequência na atualização da campanha.


### 2.0 Inicializando o ajuste:

O controle de agentes ativos por ponto de atendimento é armazenado nas tabelas ``sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util`` e ``sdx_excelencia_comercial.camp_incentivo__bemaqui_vigente.int__participantes_dia_util``. Elas possuem todos os dias úteis do mês vigente para cada matrícula ativa. O trabalho a ser realizado aqui é atualizar esta tabela com as devidas correções de férias e afastamentos.

As informações de férias, afastamentos e transferências é nos passada através do formulário de solicitações. Os responsáveis encaminham uma resposta ao documento, informando o tipo e as respectivas datas, nas quais o colaborador estará indisponível no ponto de atendimento.


### 2.1 Formulário:

O primeiro passo envolve uma tratativa do formulário para que este possa ser compilado devidamente. Para acessá-lo, basta clicar no seguinte link e você será redirecionado para sua página. 

  * [Formulário](https://docs.google.com/forms/d/132G94v3b3_ARW8Av-g0MYTq718l9n01_tJnyntrgnvk/edit#responses)

Já na página, você poderá ter acesso ás respostas dos responsáveis de cada ponto de atendimento com suas respectivas solicitações. Clicando em *Link para o app Planilhas* o arquivo será baixado para sua máquina.

O primeiro tratamento a se fazer é eliminar todas as respostas das campanhas anteriores, deixando apenas os novos registros da campanha vigente. Faça isso, filtrando a coluna **campanha** com todos os registros com excessão da camapanha do mês vigente. Posteriormente, exclua todas as linhas. Limpe o filtro e agora você terá apenas as solicitações do mês. 

Em seguida, é necessário ajustar a coluna de **matrícula**. Este campo pode conter valores com espaços, caracteres em minúsculos e a caracteres a mais. Padronize este campo removendo espaços em branco, tanto a esquerda quanto a direita, deixando os caracteres em maiúsculo e com o tamanho igual a 7. Registros com tamanhos menores não deverão ser considerados.

O próximo tratamento será uma verificação nas solicitações de transferência. Para esse tipo de solicitação, os campos referentes as datas de início e data de retorno deverão permanecer em branco. Execute um filtro na coluna de **transferência**, onde o ponto de atendimento é preenchido, filtre todos os valores diferentes de vazio. Estas são as solicitações de transferência. Para esses casos, exclua todos os valores das colunas de data de início e data de retorno, deixando-os em branco. 

Se tratando dos campos de **data de início** e **data de retorno**, certifique-se que o formato do campo seja equivalente ao exemplo a seguir:

``
Exemplo de formato: 01/01/2024
``

Já para o campo de **data da solicitação**, o formato deverá ser ``aaaa-mm-dd hh:mm:ss``, equivalente ao exemplo a seguir:

``
Exemplo de formato: 2024-01-01 10:30:10
``

O proxímo passo é salvar o documento. Ao fazê-lo, altere o nome do arquivo para ``int_forms_ferias_afastamentos`` e salve-o no formato ``.csv (separado por vírgula)``, garantindo que ele possa ser interpretado pelo código e transformado em uma tabela, posteriormente, no banco de dados. Feito isso, copie o arquivo, cole-o na pasta: ``K:\GEC\2024\04. Dados\0_Snowflake\1_Campanhas\dbt_marts_incrementais_campanhas\seeds`` e abra o projeto ``dbt_marts_incrementais_campanhas`` no **Visual Studio Code**.


### 2.2 Arquivo .CSV:

Feito isso, caso seja a primeira vez a se executar este projeto em sua máquina, será necessário configurar o arquivo ``profiles.yml``. Este arquivo se encontra no diretório ``C:\Users\XXXXXX\.dbt``. Copie o código contido no arquivo ``profile.yml`` do projeto ``dbt_marts_incrementais_campanhas`` e adicione-o no arquivo ``profiles.yml`` da sua máquina. Salve o arquivo e abra o projeto novamente. Caso não seja a primeira vez, ignore a etapa anterior e siga para os próximos passos.

Com o projeto ``dbt_marts_incrementais_campanhas`` aberto no **VS Code**, vá até o arquivo ``int_forms_ferias_afastamentos.csv``, clique nele para abri-lo. A primeira alteração a ser feita neste arquivo ``.csv`` será em seu cabeçalho, ou seja, a primeira linha do arquivo. Substitua-o para: 

``DTA_SOLICITACAO,E_MAIL,MATRICULA,CAMPANHA,COLAB_PROMOVIDO,NOM_PTO_TRANSF,DTA_SAIDA,DTA_RETORNO``

Esta mudança é feita para que o projeto, ao executar, reconheça os campos da tabela ``sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos``, já existente no banco de dados, para atualização de seus registros com as informações do arquivo ``int_forms_ferias_afastamentos.csv``.

Esta tabela, por sua vez, é usada como base para a tabela ``sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.mrt_ferias_afastamentos``, que é a base da tabela ``sdx_excelencia_comercial.camp_incentivo__bemaqui_vigente.int__participantes_dia_util``, na qual consta todos os dias úteis para cada matrícula ativa durante o período da campanha vigente.

A próxima mudança envolve substituir o ponto e vírgula (;) pela vígula (,). É possível fazer isso com o atalho ``Ctrl + f``. Um box será aberto no canto superior, clique na seta que antecede o box de escrita. Um novo box irá aparecer abaixo. No primeiro box, digite o valor no qual deseja buscar para substituir, no caso, o ponto e vírgula (;). No segundo, digite o valor o qual você deseja que seja o substituto, no caso, a vírgula (,). Salve o arquivo posteriormente.


### 2.3 Migração de dados para o Snowflake:

Tratado o arquivo ``.csv``, iremos migrar os registros da planilha para o nosso *data warehouse*, o *Snowflake*. Com o projeto ``dbt_marts_incrementais_campanhas`` aberto no **VS Code**, use o atalho ``Ctrl + '`` para abrir o terminal da *IDE*. 

A princípio, execute o comando ``dbt debug``, no terminal, para testar a conexão do banco de dados. Certifique que as informações de coexão exibidas estejam corretas como o esquema, o usuário e a senha. Ao final da execução, uma mensagem de sucesso deverá ser exibida.

<img width="321" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/01804f47-3d4e-4cbc-aed9-fa2b67656ce7">

Em seguida, ainda no terminal, execute o comando ``dbt seed``, conforme exemplo abaixo. Este será responsável por carregar os arquivos ``.csv`` localizados no diretório ``seed-paths`` do projeto dbt ``dbt_marts_incrementais_campanhas``.

``
Exemplo:
dbt seed --select "int_forms_ferias_afastamentos"
``

Afim de verificar as novas atualizações, basta consultar, no **Snowflake**, a tabela ``sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos``. Em um novo *notebook* cole a seguinte query:

``
SELECT * FROM sdx_excelencia_comercial.camp_incentivo__marts_auxiliares.int_forms_ferias_afastamentos
ORDER BY dta_solicitacao
``


### 2.4 Migração de dados para a nuvem da AWS:

Com os novos registros de férias e afastamentos da campanha vigente na tabela, iremos executar essas alterações no diretório do **Devops**, na **AWS**. 

Para migrar o projeto **DBT** da máquina para a **AWS** é necessário conectarmos remotamente na nuvem, através do protocolo **SSH**. Logo, no **VS Code**, no canto inferior esquerdo, há um ícone com duas setas de maior e menor que (><), selecione este para abrir uma janela remota. Um pop-up irá aparecer, você deverá selecionar a opção *Conectar-se ao Host...*.

<img width="590" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/343d20b6-9ede-456d-b190-11eaad28f104">

Na sequência, selecione o host ao qual se deseja conectar: ``10.221.0.36``.

<img width="575" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/044e1846-e2d8-4b1f-afc5-e1978bd83b98">

Uma nova **IDE** do **VS Code** será aberta e solicitará ao usuário que informe a senha de conexão:

<img width="695" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/63461ccb-0223-415c-b2f3-2e449b0acde7">

Após informar a senha, o **VS Code** deverá indicar a conexão remota no canto inferior esquerdo:

<img width="413" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/e4e64dbb-664a-4fe3-babc-6d63469d74a4">

Agora, clique no *Explorador de Arquivos*, em seguida, *Abrir Pasta*, para navegar no diretório da máquina em nuvem.

<img width="572" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/b9d56158-5e07-4896-b313-a1e803823ecd">

Automaticamente o diretório do seu usuário será preenchido na barra de pesquisa ao centro, selecione o ``ok`` para entrar nele. 

<img width="755" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/d3edb92f-9e33-4032-8e8d-8205890712b7">

O sistema, novamente, irá solicitar a senha, informe-a e na sequência dê o ``Enter``. Feito isso, sua **IDE** deverá se parecer com a imagem abaixo:

<img width="960" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/34f59ccc-3967-4a2b-8418-0c475fbc7998">

Conectato remotamente a nuvem, é necessário fazer login na **AWS** para salvar qualquer alteração em seu diretório. Logo, com o atalho ``Ctrl + '``, abra o terminal do **VS Code** e, em seguida, digite a linha de comando ``aws sso login``. 

Um pop-up será exibido, e nele, clique o botão *Abrir*.

<img width="292" alt="image" src="https://github.com/Banco-Mercantil/ssh_installation/assets/88452990/bad2ea14-77a8-422d-8a16-b6402388a3b6">

Nesta etapa, o sistema irá abrir uma guia da **AWS** no navegador, autorize a conexão pelo app *Authenticator*, cliquei no botão *Confirm and continue* para seguir. Na sequência clique em *Allow access*, ao final você deverá visualizar essa mensagem na guia do navegador:

<img width="329" alt="image" src="https://github.com/Banco-Mercantil/ssh_installation/assets/88452990/e14052ca-0c29-4cbe-abb6-8fc0f32b4f79">

Você poderá fechar a guia aberta neste momento e retornar ao **VS Code**. 

Após logado, o primeiro passo a ser feito é executar um ``pull`` para que os arquivos e configurações que constam no repositório sejam carregados para a sua máquina. Para isso, utilize o atalho ``Ctrl + Shift + G`` para acessar a guia de controle do código-fonte. Você deverá visualizar um box, na lateral esquerda, referente ao servidor da **AWS** e um segundo box, logo abaixo, referente ao **Airflow**. Clique nos *três pontinhos* e selecione a opção *Efetuar Pull*. 

<img width="685" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/fd8a5e2e-3369-414c-bd63-6beeb5b86d7c">

Feito isso, utilize o atalho ``Ctrl + Shift + e`` para acessar o **Explorador** do **VS Code**. Através dele, navegue até a pasta ``/home/XXXXXXX/MB.AWS.BIZ.GEC/1_Campanhas/dbt_marts_incrementais_campanhas/seeds``. Aqui, exclua o arquivo ``int_forms_ferias_afastamentos.csv``, pois esse encontra-se desatualizado para a campanha vigente.

Agora, no **Explorador de Arquivos** da máquina, vá para o arquivo ``dbt_marts_incrementais_campanhas``, o qual se encontra atualizado com as novas solicitações de férias e afastamentos, através do caminho: ``K:\GEC\2024\04. Dados\0_Snowflake\1_Campanhas\dbt_marts_incrementais_campanhas``. Entre na pasta ``seeds`` e copie o arquivo ``int_forms_ferias_afastamentos.csv``.

Retorne para o **VS Code**, conectado a **AWS**, e cole o arquivo copiado na pasta ``seeds`` do projeto ``/home/XXXXXXX/MB.AWS.BIZ.GEC/1_Campanhas/dbt_marts_incrementais_campanhas``.

![image](https://github.com/Banco-Mercantil/adjust_vacation_transfer/assets/88452990/a2a0e5d4-e0ef-4944-961b-1d3b21d7703e)

Salve as alterações.

Nesta etapa, use o terminal e navegue para a pasta ``XXXXXXX@ip-10-221-0-36:/home/XXXXXX/MB.AWS.BIZ.GEC/1_Campanhas/dbt_marts_incrementais_campanhas``.

Na sequência, digite o código: ``.\build_push_dev.sh``. O sistema irá gerar um novo executável após as configurações feitas. Ao finalizar o processamento da ``build``, vamos salvar as alterações que acabamos de migrar para a nuvem. 

Utilize o atalho ``Ctrl + Shift + G`` para acessar a guia de controle do código-fonte. No box do servidor da **AWS**, ``MB.AWS.BIZ.GED``, digite uma mensagem relevante para salvar as alterações: ``Ajuste férias e afastamentos maio 2024`` e clique no botão *Commit* e em seguida clique no botão *Sync changes*. Um pop-up de confirmação será aberto, basta clicar em *Yes*.

<img width="594" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/91603c66-6012-4ad6-b940-b64ba82828ba">


### 2.5 Limpar as tabelas do esquema vigente:

Com a atualização dos registros de férias e afastamentos na tabela ``sdx_excelencia_comercial.camp_incentivo_marts_auxiliares.int_forms_ferias_afastamentos``, é necessário realizar os devidos ajustes nas tabelas vigentes da campanha. Desta forma, para que haja o reprocessamento dos dados e, posteriormente, o cálculo das metas individuais dos colaboradores, levando em consideração a quantidade de agentes ativos em cada ponto de atendimento por dia útil do mês.

Para isso, em uma guia do navegar, acesse o [Snowflake](https://app.snowflake.com/kdumwgr/dda57677/w4a61L0P8DQR/query). Em um *notebook* (editor de texto da ferramenta), execute as seguintes instruções para limpar os dados das respectivas tabelas.

#### 2.5.1 Campanha Rede:

--LIMPA TABELA DE PARTICIPANTES POR DIA UTIL 
--OBs.: Esta tabela não poderá ficar sendo truncada
TRUNCATE TABLE sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util;

--LIMPA TABELA DE METAS DE EMPRESTIMO
TRUNCATE TABLE sdx_excelencia_comercial.camp_incentivo__rede_vigente.int_metas__individuais;

--LIMPA TABELA DE METAS DE DPZ
TRUNCATE TABLE sdx_excelencia_comercial.camp_incentivo__rede_vigente.int_dpz__metas;

#### 2.5.2 Campanha Bem Aqui:

--LIMPA TABELA DE PARTICIPANTES POR DIA UTIL 
--OBs.: Esta tabela não poderá ficar sendo truncada
TRUNCATE TABLE sdx_excelencia_comercial.camp_incentivo__bemaqui_vigente.int__participantes_dia_util;

--LIMPA TABELA DE METAS DE EMPRESTIMO
TRUNCATE TABLE sdx_excelencia_comercial.camp_incentivo__bemaqui_vigente.int_metas__individuais;


### 3.0 Habilitar execução da DAG no Airflow:

Feito todas as devidas modificações, é possível reabilitar a execução agendada do projeto ``dbt_marts_incrementais_campanhas``.

Para tal, acesse o site do *[Airflow](https://airflow.real-dev.n-mercantil.com.br/home)* com seu login e senha.

Com o site aberto, localize a *DAG* ``dbt-marts_incrementais_campanhas`` e clique em seu nome. Você será redirecionado para uma nova tela e nela basta habilitar a atualização agendada, conforme a imagem abaixo:

![image](https://github.com/Banco-Mercantil/campaign_update/assets/88452990/9eebadbe-8205-41bb-8308-ee214eb7293b)


### 4.0 Visualização de ajustes nos dashboards:

Afim de confirmar as alterações acima nos dashboards, basta aguarda a próxima atualização de ambos, CAMAPANHA INCENTIVO REDE e CAMAPANHA INCENTIVO BEM AQUI. Após atualizado, as alterações deverão estar visíveis nos respectivos BI's.




