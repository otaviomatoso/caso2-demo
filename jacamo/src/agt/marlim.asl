// CASO 2 - DEMO

/* Initial beliefs and rules */
url("http://node-red:1880/marlim"). // (docker) url dummy marlim

/* Initial goals */
!start.

/* Plans */
+!start : url(U)
	<- register(U);
     .print("ag_marlim iniciado");
  .

+!espera_teste[scheme(s1)]
	<- .print("esperando teste na plataforma");
		 .wait({+novo_teste(Poco)[source(marlim)]}); // novo_teste é um sinal emitido pelo dummy
		 -+teste(Poco);
		 .print("teste detectado no poco (", Poco, ")");
	.

+!run_marlim[scheme(s1)] : teste(Poco)
	<- .print("executando a analise de sensibilidade para o poco (", Poco, ")");
		 Run_as =.. [run_as,[Poco],[]]; // run_as é operação no marlim dummy
		 act(Run_as, Res); // Res = resposta da operacao (nome do arquivo AS gerado)
		 .print("analise de sensibilidade finalizada");
		 .print("arquivo (", Res, ") gerado");
		 -+as(Poco,Res); // crença da analise de sensibilidade, com nome do poço e nome do arquivo AS
	.


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-obedient.asl") }
