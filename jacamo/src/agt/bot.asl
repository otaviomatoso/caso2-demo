// CASO 2 - DEMO

/* Initial beliefs and rules */
ultimo_lista(L, U) :- .length(L, N) & .nth(N-1, L, U).

/* Initial goals */
!start.

/* Plans */
+!start <- .print("ag_bot iniciado").

+!contactar_eng[scheme(s1)]
	<- .print("avisando o engenheiro sobre novos resultados de otimizacao...");
		 .send(ag_eng, signal, "novos resultados de otimizacao disponiveis");
		 .wait({+validacao_eng}); // aguarda validacao do engenheiro
	.

-!contatar_eng <-	.print("erro ao contatar engenheiro").

// Se receber uma mensagem sobre um novo teste
+mensagem(M)
	<-	calculaResposta(M,R);
			if(.substring("XRESUMOPOCO_", R)){
				.findall(I, .substring("_", R, I),[I1|_]);
				.substring(R, Poco, I1+1, .length(R));
				.send(ag_brsiop, askOne, gln(_), gln(Gln));
				extraiInformacao(Poco, Gln, Resumo);
				.concat("Poco ", Poco, ":\n", Resumo, Resultado);
				.send(ag_eng, signal, Resultado);
			}
			elif(R == "XRESUMOGERAL"){
				.send(ag_brsiop, askOne, gln(_), gln(Gln));
				extraiInformacao("", Gln, Resumo);
				.concat("Informacoes gerais:\n", Resumo, Resultado);
				.send(ag_eng, signal, Resultado);
			}
			elif(R == "XREOTIMIZAR"){
				.send(ag_eng, signal, "processo de otimizacao sendo refeito...");
				resetGoal("run_glc");
				// .send(ag_engineer, achieve, fim);
			}
			elif(.substring("XSET_", R)){
				.findall(I, .substring("_", R, I),[I1,I2|_]);
				.substring(R, Nome_tag, I1+1, I2);
				.substring(R, Nome_poco, I2+1, .length(R));

				.send(ag_brsiop, askOne, gln(_), gln(Gln));
				extraiSaida(Nome_poco, Nome_tag, Gln, Valor_tag);
				if (Valor_tag == -1){
					.send(ag_eng, signal, "nenhum poco encontrado com este nome.");
				} elif (Valor_tag == -2){
					.send(ag_eng, signal, "nenhuma tag encontrada com este nome.");
				}
				else{
					-+set_mpa(Valor_tag);
					-+validacao_eng;
				}
			}
			else{
				.send(ag_eng, signal, R);
			};
			.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }
