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


Tratado o arquivo ``.csv``, iremos migrar os registros da planilha para o nosso *data warehouse*. A princípio, execute o comando ``dbt debug``, no terminal, para testar a conexão do banco de dados e exibir informações para fins de depuração. Ao final da execução, uma mensagem de sucesso deverá ser exibida.

<img width="321" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/01804f47-3d4e-4cbc-aed9-fa2b67656ce7">

O comando ``dbt seed`` irá carregar os arquivos ``.csv`` localizados no diretório ``seed-paths`` do projeto dbt ``dbt_marts_incrementais_campanhas``. Logo, abra o terminal do **VS Code** e execute o seguinte trecho de código:

``
dbt seed --select "int_forms_ferias_afastamentos"
``

Afim de verificar as novas atualizações, basta consultar, no **Snowflake**, a tabela ``SDX_EXCELENCIA_COMERCIAL.CAMP_INCENTIVO__MARTS_AUXILIARES.INT_FORMS_FERIAS_AFASTAMENTOS``. Em um novo *notebook* cole a seguinte query:

``
SELECT * FROM SDX_EXCELENCIA_COMERCIAL.CAMP_INCENTIVO__MARTS_AUXILIARES.INT_FORMS_FERIAS_AFASTAMENTOS
ORDER BY DTA_SOLICITACAO DESC
``

Com os novos registros da campanha vigente na tabela, iremos executar essas alterações no diretório da **AWS**. 

Para migrar o projeto *DBT* da máquina para a *AWS* é necessário conectarmos remotamente na nuvem, através do protocolo *SSH*. Logo, no *VS Code*, no canto inferior esquerdo, há um ícone com duas setas de maior e menor que (><), selecione este para abrir uma janela remota. Um pop-up irá aparecer, você deverá selecionar a opção *Conectar-se ao Host...*.

<img width="590" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/343d20b6-9ede-456d-b190-11eaad28f104">

Na sequência, selecione o host ao qual se deseja conectar: ``10.221.0.36``.

<img width="575" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/044e1846-e2d8-4b1f-afc5-e1978bd83b98">

Uma nova *IDE* do *VS Code* será aberta e solicitará ao usuário que informe a senha de conexão:

<img width="695" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/63461ccb-0223-415c-b2f3-2e449b0acde7">

Após informar a senha, o *VS Code* deverá indicar a conexão remota no canto inferior esquerdo:

<img width="413" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/e4e64dbb-664a-4fe3-babc-6d63469d74a4">

Agora, clique no *Explorador de Arquivos*, em seguida, *Abrir Pasta*, para navegar no diretório da máquina em nuvem.

<img width="572" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/b9d56158-5e07-4896-b313-a1e803823ecd">

Automaticamente o diretório do seu usuário será preenchido na barra de pesquisa ao centro, selecione o ``ok`` para entrar nele. 

<img width="755" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/d3edb92f-9e33-4032-8e8d-8205890712b7">

O sistema, novamente, irá se solicitar a senha, informe-a e na sequência dê o ``Enter``. Feito isso, sua *IDE* deverá se parecer com a imagem abaixo:

<img width="960" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/34f59ccc-3967-4a2b-8418-0c475fbc7998">

Conectato remotamente a nuvem, é necessário logar a AWS para fazer qualquer alteração no *Airflow*. Nesta fase, digite, então, a linha de comando ``aws sso login``. Um pop-up será exibido, e nele, clique o botão *Abrir*.

<img width="292" alt="image" src="https://github.com/Banco-Mercantil/ssh_installation/assets/88452990/bad2ea14-77a8-422d-8a16-b6402388a3b6">

Nesta etapa, o sistema irá abrir um navegador da *AWS*, autorize a conexão pelo app *Authenticator*, cliquei no botão *Confirm and continue* para seguir. Na sequência clique em *Allow access*, ao final você deverá receber esta mensagem:

<img width="329" alt="image" src="https://github.com/Banco-Mercantil/ssh_installation/assets/88452990/e14052ca-0c29-4cbe-abb6-8fc0f32b4f79">

Você poderá fechar o navegador neste momento e retornar ao *VS Code*. Após logado, o primeiro passo a ser feito é executar o comando ``pull`` para que os arquivos e configurações que constam no repositório sejam carregados para a sua máquina. 

Utilize o atalho ``Ctrl + Shift + G`` para acessar a guia de controle do código-fonte. Clique nos *três pontinhos* e selecione a opção *Efetuar Pull*. 

<img width="685" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/fd8a5e2e-3369-414c-bd63-6beeb5b86d7c">

Nesta etapa, use o terminal e vá para o diretorio ``/home/pfernandes/MB.AWS.BIZ.GEC/1_Campanhas/dbt_marts_incrementais_campanhas``. Substitua o arquivo ``int_forms_ferias_afastamentos.csv`` pelo mesmo arquivo que consta em sua máquina que acabou de ser atualizado. Salve as alterações.

Na sequência, digite o código: ``.\build_push_dev.sh``. O sistema irá gerar um novo executável após as configurações feitas. Ao finalizar o processamento da ``build``, vamos salvar as alterações no *Airflow*. 

Utilize o atalho ``Ctrl + Shift + G`` para acessar a guia de controle do código-fonte. No box do *Airflow*, digite uma mensagem relevante para salvar as alterações: ``Ajuste férias e afastamentos maio 2024`` e clique no botão *Commit*. Um pop-up de confirmação será aberto, basta clicar em *Yes*.

<img width="594" alt="image" src="https://github.com/Banco-Mercantil/campaign_update/assets/88452990/91603c66-6012-4ad6-b940-b64ba82828ba">

Na sequência, clique no botão *Sync changes* que aparecerá em seguida.

Agora vamos salvar as alterações no repositório DevOps ``MB.AWS.BIZ.GED``. No box do repositório,  digite uma mensagem relevante para salvar as alterações: ``Ajuste férias e afastamentos maio 2024`` e clique no botão *Commit*. Um pop-up de confirmação será aberto, basta clicar em *Yes*.

O sistema irá solicitar o usuário (matrícula) e a senha, informe-os, respectivamente, e dê o ``Enter``. Verifique a confirmação das alterações no histórico do [devops](https://devops.mercantil.com.br/Tecnologia_MB/MB/_git/MB.AWS.BIZ.GEC).

Com a atualização dos nos registros de férias, afawstamentos e transferências na tabela ``SDX_EXCELENCIA_COMERCIAL.CAMP_INCENTIVO__MARTS_AUXILIARES.INT_FORMS_FERIAS_AFASTAMENTOS``, é necessário realizar os devidos ajustes na tabela ``sdx_excelencia_comercial.camp_incentivo__rede_vigente.int__participantes_dia_util``, a qual registra todas os dias úteis do mês para cada matrícula ativa. 


### Férias ou Afastamentos:

A começar pelo ajuste das solicitações de férias dos colaboradores, acesse a plataforma do [Snowflake](https://app.snowflake.com/kdumwgr/dda57677/w4yRXGS5uLsB/query). Vá para a guia *Worshets*, abra um novo *notebook* para digitar códigos em *SQL* e certifique de indicar a role e o data warehouse corretos:


![An image of foo bar for GitHub Free, GitHub Pro, GitHub Team, and GitHub Enterprise Cloud](C:\Users\B045523\Pictures\Screenshots\Captura de tela 2024-05-16 183044.png)





### Transferência de Agencia:





# corrigir a tabela de participantes de dia util e dar um truncate nas metas individuais:











3 - int_metas__individuais



