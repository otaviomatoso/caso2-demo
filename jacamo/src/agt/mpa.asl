// Agent chatbot in project chatbot_jacamo

/* Initial beliefs and rules */
// url("http://node-red:1880/mpa"). // (docker) url dummy mpa
url("http://localhost:1880/mpa"). // (local) url dummy mpa
tag("ufsc.v1_abertura").
url_eng("http://localhost:1880/ag_eng"). // (local) url dummy ag_eng

/* Initial goals */
!start.

/* Plans */
+!start : url(U)
	<- register(U);
     .print("ag_mpa iniciado");
  .

+!atuar_planta[scheme(s1)] : tag(Tag) & url_eng(Ag_eng)
	<- .print("pedindo ao ag_bot valor a ser inserido na planta...");
		 .send(ag_bot, askOne, set_mpa(Valor), set_mpa(Valor));
		 Set_mpa =.. [set_mpa,[Tag,Valor],[]];
     .print("atuando na planta via MPA...");
     act(Set_mpa, Res);
     .print("resposta do MPA: ", Res);
		 .concat("tag (",Tag,") foi atualizada com valor (",Valor,") no MPA", Response);
     // .print("tag (",Tag,") foi atualizada com valor (",Valor,") no MPA.");
		 .print(Response);
		 .send(Ag_eng, signal, Response);
		 !!restart;
  .

+!restart <- resetGoal("espera_teste").

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
