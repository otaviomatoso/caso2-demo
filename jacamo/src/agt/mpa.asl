// Agent chatbot in project chatbot_jacamo

/* Initial beliefs and rules */
tag("ufsc.v1_abertura").

/* Initial goals */
!iniciar.

/* Plans */

+!iniciar
	<- 	.print("Agente MPA iniciado.");
			focus(mpa);
			.

+!atuar_planta : tag(Tag)
	<- .print("pedindo ao ag_bot valor a ser inserido na planta...");
		 .send(ag_bot, askOne, set_mpa(Valor), set_mpa(Valor));
		 Set_mpa =.. [set_mpa,[Tag,Valor],[]];
     .print("atuando na planta via MPA...");
     act(Set_mpa, Res);
     .print("resposta do MPA: ", Res);
     .print("tag (",Tag,") foi atualizada com valor (",Valor,") no MPA.");
  .

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
