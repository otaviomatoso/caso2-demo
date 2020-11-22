package tools;

import cartago.*;
import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import org.xml.sax.SAXException;

public class DomArtifact extends Artifact {

    DomClass dom;
    int count;
    void init() {
        dom = new DomClass();
        count = 0;
    }

    @OPERATION
    void checkWell(String well, String file, OpFeedbackParam<String> output) throws SAXException, IOException, ParserConfigurationException, TransformerException {
        count = count + 1;
        output.set(DomClass.checkWell(well, file, count));
    }

    @OPERATION
  	void extraiInformacao(Object entrada, Object arquivo, OpFeedbackParam<String> saida) throws ParserConfigurationException, SAXException, IOException {
  		String entradaStr = entrada.toString();
  		String arquivoStr = arquivo.toString();
  		String resposta = DomClass.extraiInformacao(entradaStr, arquivoStr);
  		saida.set(resposta);
  	}
    
  	@OPERATION
  	void extraiSaida(Object entradaPoco, Object entradaTag, Object arquivo, OpFeedbackParam<Double> saida) throws ParserConfigurationException, SAXException, IOException {
  		Double resposta = DomClass.extraiInformacao(entradaPoco.toString(), entradaTag.toString(), arquivo.toString());
  		saida.set(resposta);
  	}
}
