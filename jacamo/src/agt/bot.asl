// CASO 2 - DEMO

/* Initial beliefs and rules */
// url("http://node-red:1880/ag_eng"). // (docker) url dummy ag_eng
url("http://localhost:1880/ag_eng"). // (local) url dummy ag_eng
ultimo_lista(L, U) :- .length(L, N) & .nth(N-1, L, U).

/* Initial goals */
!start.

/* Plans */
+!start <- .print("ag_bot iniciado").

+!contactar_eng[scheme(s1)] : url(Ag_eng)
	<- .print("contactando engenheiro...");
		 .send(Ag_eng, signal, "novos resultados de otimizacao disponiveis");
		 .wait({+validacao_eng}); // aguarda validacao do engenheiro
	.

-!contactar_eng <-	.print("erro ao contatar engenheiro").

// Se receber uma mensagem sobre um novo teste
+mensagem(M) : url(Ag_eng)
	<-	calculaResposta(M,R);
			if(.substring("XRESUMOPOCO_", R)){
				.findall(I, .substring("_", R, I),[I1|_]);
				.substring(R, Poco, I1+1, .length(R));
				.send(ag_brsiop, askOne, otm_out(_), otm_out(Gln));
				extraiInformacao(Poco, Gln, Resumo);
				.concat("Poco ", Poco, ":\n", Resumo, Resultado);
				.send(Ag_eng, signal, Resultado);
			}
			elif(R == "XRESUMOGERAL"){
				.send(ag_brsiop, askOne, otm_out(_), otm_out(Gln));
				extraiInformacao("", Gln, Resumo);
				.concat("Informacoes gerais:\n", Resumo, Resultado);
				.send(Ag_eng, signal, Resultado);
			}
			elif(R == "XREOTIMIZAR"){
				.send(Ag_eng, signal, "processo de otimizacao sendo refeito...");
				resetGoal("run_glc");
				// .send(Ag_engineer, achieve, fim);
			}
			elif(.substring("XSET_", R)){
				.findall(I, .substring("_", R, I),[I1,I2|_]);
				.substring(R, Nome_tag, I1+1, I2);
				.substring(R, Nome_poco, I2+1, .length(R));

				.send(ag_brsiop, askOne, otm_out(_), otm_out(Gln));
				extraiSaida(Nome_poco, Nome_tag, Gln, Valor_tag);
				if (Valor_tag == -1){
					.send(Ag_eng, signal, "nenhum poco encontrado com este nome.");
				} elif (Valor_tag == -2){
					.send(Ag_eng, signal, "nenhuma tag encontrada com este nome.");
				}
				else{
					-+set_mpa(Valor_tag);
					-+validacao_eng;
				}
			}
			else{
				.send(Ag_eng, signal, R);
			};
	.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
