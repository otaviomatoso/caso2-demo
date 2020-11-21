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
        // getObsProperty("cont");
        count = count + 1;
        // c.updateValue(n+1);
        // getObsProperty("status").updateValue("open");
        output.set(DomClass.checkWell(well, file, count));
        // n = getObsProperty("cont").intValue();
        // System.out.println("Valor de n = " + n);
        // if(n==2){
        //   dom.setFile(file);
        // }
    }
    // @OPERATION
    // void setFile(String file, OpFeedbackParam<Double> result) throws SAXException, IOException, ParserConfigurationException, TransformerException {
    //     output.set(DomClass.setWell(file));
    // }
}
