// CASO 2 - DEMO

/* Initial beliefs and rules */
url("http://node-red:1880/brsiop"). // (docker) url dummy brsiop
username("jomi"). // BR-SiOP usuario
password("hubner"). // BR-SiOP senha
gln("P-40_2020.gln"). // arquivo GLN de entrada para otimização
otm("otm.gln"). // arquivo GLN de saída, com os resultados da otimização
pocos([]). // lista de poços

/* Initial goals */
!start.

/* Plans */
+!start : url(U)
  <- register(U);
     .print("ag_brsiop iniciado");
     !!login;
  .

-!start <- .print("erro ao iniciar").

+!login : username(U) & password(P)
  <- .print("iniciando login no sistema BR-SiOP...");
     Login =.. [login,[U,P],[]];
     act(Login, T); // BR-SiOP authentication
     +token(T);
     .print("ag_brsiop autenticado no sistema");
  .

-!login <- .print("erro ao realizar login no sistema BR-SiOP").

+!run_tab_glc[scheme(s1)] : token(T) & gln(Gln) & pocos(Lista)
  <- .print("pedindo ao ag_marlim dados sobre a analise de sensibilidade...");
     .send(ag_marlim, askOne, as(Poco, As), as(Poco, As));
     .print("nome do poco: ", Poco);
     .print("nome do arquivo AS: ", As);
     .concat(Lista, [Poco], NL); // NL: Nova Lista de poços
		 -+pocos(NL);
     !upload_brsiop(Gln);
     // !upload_brsiop(As); // por ser grande, arquivo AS já está no servidor
     Tab_glc =.. [tab_glc,[T,Poco,Gln,As],[]];
     .print("executando TAB/GLC...");
     act(Tab_glc, JobId);   // aplicação TAB/GLC do BR-SiOP
     .print("ID de execucao: ", JobId);
     !espera_exec(JobId); // espera o fim da execução
     !download_brsiop(Gln);
     .print("arquivo GLN foi atualizado com dados do poco (", Poco, ")");
  .

-!run_tab_glc <- .print("erro ao executar TAB/GLC").

+!run_glc[scheme(s1)] : pocos(Lista) & .length(Lista,N) & N < 2
  <- .print("lista atual de pocos: ", Lista);
     .print("nao ha pocos suficientes para realizar a otimizacao. Reiniciando processo...");
     .resetGoal("espera_teste");
  .

+!run_glc[scheme(s1)] : token(T) & gln(In) & otm(Out)
   <- .print("preparando para executar a otimizacao...");
      !upload_brsiop(In);
      GLC =.. [glc,[T,In,Out],[]];
      .print("executando GLC...");
      act(GLC, JobId); // aplicação GLC do BR-SiOP
      .print("ID de execucao: ", JobId);
      !espera_exec(JobId); // espera o fim da execução
      !download_brsiop(Out);
      .print("fim do processo de otimizacao");
   .

+!upload_brsiop(Arquivo) : token(T)
  <- .print("upload do arquivo: ", Arquivo);
     Upload =.. [upload,[T,Arquivo],[]];
     act(Upload, Res);
     .print("resposta do upload: ", Res);
  .

+!download_brsiop(Arquivo) : token(T)
  <- .print("download do arquivo: ", Arquivo);
     Download =.. [download,[T,Arquivo],[]];
     act(Download, Res);
     .print("resposta do download: ", Res);
  .

+!espera_exec(J) : token(T)
   <- JobInfo =.. [jobInfo,[T,J],[]];
      act(JobInfo, S);
      .print("status: ", S);
      if (S \== "FINISHED") {
        .wait(3000);
        !espera_exec(J);
      } else { .print("execucao do processo (", J, ") finalizada"); }
      .

-!espera_exec(J) <- .print("erro ao executar processo (", J, ")").

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
