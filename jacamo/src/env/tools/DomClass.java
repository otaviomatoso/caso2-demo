package tools;

import org.w3c.dom.*;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.parsers.*;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import java.io.*;
import java.util.ArrayList;

public class DomClass {
    static ArrayList < String > listaInformacoesEntradaPoco = new ArrayList < String > ();
    static ArrayList < String > listaInformacoesSaidaPoco = new ArrayList < String > ();
    static ArrayList < String > listaInformacoesSaidaGerais = new ArrayList < String > ();
    static String nomeTagEntradaPocos = "wells";
    static String nomeTagEntradaPoco = "well";
    static String nomeTagSaidaGeral = "output";
    static String nomeTagSaidaPocos = "welloutput";

    DomClass() {
        listaInformacoesEntradaPoco.add("Status");
        listaInformacoesEntradaPoco.add("QglFixed");
        listaInformacoesEntradaPoco.add("QglMin");
        listaInformacoesEntradaPoco.add("QglMax");
        listaInformacoesEntradaPoco.add("QglRatesArray");
        listaInformacoesEntradaPoco.add("QglRatesMin");
        listaInformacoesEntradaPoco.add("QglRatesMax");
        listaInformacoesEntradaPoco.add("QglWhpRatesArray");
        listaInformacoesEntradaPoco.add("QglWhpRatesMin");
        listaInformacoesEntradaPoco.add("QglWhpRatesMax");
        listaInformacoesEntradaPoco.add("QglQoRatesMatrix");
        listaInformacoesEntradaPoco.add("PHeadFixed");
        listaInformacoesEntradaPoco.add("PHeadMin");
        listaInformacoesEntradaPoco.add("PHeadMax");
        listaInformacoesEntradaPoco.add("GOR");
        listaInformacoesEntradaPoco.add("WC");
        listaInformacoesEntradaPoco.add("Potential");
        listaInformacoesEntradaPoco.add("AllowsEmerging");
        listaInformacoesEntradaPoco.add("QglReference");
        listaInformacoesEntradaPoco.add("PHeadReference");
        listaInformacoesEntradaPoco.add("QoReference");

        listaInformacoesSaidaPoco.add("ProductionStateOptimal");
        listaInformacoesSaidaPoco.add("QglOptimal");
        listaInformacoesSaidaPoco.add("PHeadOptimal");
        listaInformacoesSaidaPoco.add("QoOptimal");
        listaInformacoesSaidaPoco.add("QgOptimal");
        listaInformacoesSaidaPoco.add("QwOptimal");

        listaInformacoesSaidaGerais.add("TotalOilRateOptimal");
        listaInformacoesSaidaGerais.add("ProducedGasOptimal");
        listaInformacoesSaidaGerais.add("ConsumedGasLiftOptimal");
        listaInformacoesSaidaGerais.add("TotalGasOptimal");
        listaInformacoesSaidaGerais.add("ProducedWaterOptimal");
        listaInformacoesSaidaGerais.add("ProducedLiquidOptimal");
        listaInformacoesSaidaGerais.add("FlareGasOptimal");
        listaInformacoesSaidaGerais.add("ExportGasRateOptimal");
        listaInformacoesSaidaGerais.add("ProductionLossOptimal");
        listaInformacoesSaidaGerais.add("EfficiencyOptimal");
        listaInformacoesSaidaGerais.add("IUGAOptimal");
        listaInformacoesSaidaGerais.add("MaxLiquidCapacity");
        listaInformacoesSaidaGerais.add("IUGAOptimal");
        listaInformacoesSaidaGerais.add("MaxWaterTreatmentCapacity");
        listaInformacoesSaidaGerais.add("CompressionCapacity");
        listaInformacoesSaidaGerais.add("MaxFlareGas");
        listaInformacoesSaidaGerais.add("FuelGas");
        listaInformacoesSaidaGerais.add("MaxExportGasRate");
    }

    private static void setFile(Document documento) throws SAXException, IOException, ParserConfigurationException, TransformerException{
      // Document documento = criaDocument(file);
      Element eWells = (Element) documento.getElementsByTagName(nomeTagEntradaPocos).item(0);
  		Element eWell = (Element) eWells.getElementsByTagName(nomeTagEntradaPoco).item(0);
  		eWell.getParentNode().removeChild(eWell);
  	}

    public static String checkWell(String well, String file, int count) throws SAXException, IOException, ParserConfigurationException, TransformerException {
        Document documento = criaDocument(file);
        documento.getDocumentElement().normalize();

        NodeList wList = documento.getElementsByTagName(nomeTagEntradaPoco);
        ArrayList < String > wellList = new ArrayList < String > ();
        for (int i = 0; i < wList.getLength(); i++) {
            Element element = (Element) wList.item(i);
            wellList.add(element.getAttribute("name"));
        }
        if (wellList.contains(well)) {
          return ("File " + file + " already contains well " + well + ". Updating its values...");
        } else {
            NodeList nList = documento.getElementsByTagName(nomeTagEntradaPocos);
            for (int temp = 0; temp < nList.getLength(); temp++) {
              Node node = nList.item(temp);
              if (node.getNodeType() == Node.ELEMENT_NODE) {
                Element eElement = (Element) node;
                eElement.insertBefore(criaPoco(documento, well), node.getLastChild());
              }
            }
            if(count==2){ setFile(documento); }
            geraArquivo(documento, file);
            return ("File " + file + " does not contain well " + well + " yet. Adding its values...");
          }
          // String[] arquivoSplit1 = arquivo.split(".gln");
          // String aux = arquivoSplit1[0];
          // String[] arquivoSplit2 = aux.split("TST");
          // int indice = Integer.parseInt(arquivoSplit2[1]);
          // // Apaga poco null apenas quando estiver no TST2
          // if (indice == 2){ apagaPoco(documento); }
    }

    private static Node criaPoco(Document doc, String nome) {
        Element well = doc.createElement("well");
        well.setAttribute("name", nome);
        for (String tag: listaInformacoesEntradaPoco) {
            if (tag == "Status") {
                well.appendChild(criaPocoElement(doc, tag, "ENABLED"));
            // } else if (tag == "Potential") {
            //     well.appendChild(criaPocoElement(doc, tag, "0.0"));
            // } else if (tag == "AllowsEmerging") {
            //     well.appendChild(criaPocoElement(doc, tag, "false"));
            } else {
                well.appendChild(criaPocoElement(doc, tag, ""));
            }
        }
        return well;
    }

    private static Node criaPocoElement(Document doc, String name, String value) {
        Element node = doc.createElement(name);
        node.appendChild(doc.createTextNode(value));
        return node;
    }

    private static Document criaDocument(String arquivo) throws SAXException, IOException, ParserConfigurationException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        builder.setEntityResolver(new EntityResolver() {
            @Override
            public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
                if (systemId.contains("gasliftnew-v1.dtd")) {
                    return new InputSource(new StringReader("\n"));
                } else {
                    return null;
                }
            }
        });
        Document document = builder.parse(new File(System.getProperty("user.dir") + "/../files/" + arquivo)); // + ".gln"));
        return document;
    }

    private static void geraArquivo(Document doc, String file) throws TransformerException {
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Transformer transf = transformerFactory.newTransformer();
        transf.setOutputProperty(OutputKeys.ENCODING, "ISO-8859-1");
        transf.setOutputProperty(OutputKeys.INDENT, "yes");
        transf.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
        DOMSource source = new DOMSource(doc);

        String userDir = System.getProperty("user.dir");
        File myFile = new File(userDir + "/../files/" + file);
        StreamResult output = new StreamResult(myFile);
        transf.transform(source, output);
    }

    public static String extraiInformacao(String poco, String arquivo) throws ParserConfigurationException, SAXException, IOException {
  		// String currentDir = System.getProperty("user.dir").replace("\\", "/");
  		String retorno = "";

  		Document document = criaDocument(arquivo);
  		// Document document = criaDocument(currentDir, arquivo);
  		document.getDocumentElement().normalize();
  		Element root = document.getDocumentElement();

  		if(poco.isEmpty()) {
  			//Pega todas as saidas
  			NodeList nList = document.getElementsByTagName(nomeTagSaidaGeral);
  			for (int temp = 0; temp < nList.getLength(); temp++){
  				Node node = nList.item(temp);
  				if (node.getNodeType() == Node.ELEMENT_NODE){
  				    Element eElement = (Element) node;
  				    for (String s : listaInformacoesSaidaGerais) {
  				    	retorno = retorno + s + " = " + eElement.getElementsByTagName(s).item(0).getTextContent() + "\n";
  				    }
  				}
  			}
  		}else {
  			NodeList nList = document.getElementsByTagName(nomeTagSaidaPocos);
  			int numeroPocosEncontrados = 0;
  			for (int temp = 0; temp < nList.getLength(); temp++){
  				Node node = nList.item(temp);
  				if (node.getNodeType() == Node.ELEMENT_NODE){
  				    Element eElement = (Element) node;
  				    String nomePoco = eElement.getAttribute("name");
  				    if(nomePoco.equalsIgnoreCase(poco)) {
  				    	numeroPocosEncontrados++;
  				    	// System.out.println("Poco " + nomePoco + ":\n");
  					    for (String s : listaInformacoesSaidaPoco) {
  					    	retorno = retorno + s + " = " + eElement.getElementsByTagName(s).item(0).getTextContent() + "\n";
  					    }
  				    }
  				}
  			}
  			if(numeroPocosEncontrados == 0) {
  				return "Nenhum poco encontrado com este nome\n";
  			}
  		}
  		return retorno;
  	}

  	public static Double extraiInformacao(String poco, String tag, String arquivo) throws ParserConfigurationException, SAXException, IOException {
  		// String currentDir = System.getProperty("user.dir").replace("\\", "/");
  		double retorno = 0;

  		Document document = criaDocument(arquivo);
  		// Document document = criaDocument(currentDir, "TST" + (indice));
  		document.getDocumentElement().normalize();
  		Element root = document.getDocumentElement();

  		if(poco.isEmpty()) {
  			NodeList nList = document.getElementsByTagName(nomeTagSaidaGeral);
  			for (int temp = 0; temp < nList.getLength(); temp++){
  				Node node = nList.item(temp);
  				if (node.getNodeType() == Node.ELEMENT_NODE){
  					Element eElement = (Element) node;
  					for (String s : listaInformacoesSaidaGerais) {
  						if (s.equals(tag)){
  							retorno = Double.parseDouble(eElement.getElementsByTagName(s).item(0).getTextContent());
  						}
  					}
  				}
  			}
  		}else {
  			NodeList nList = document.getElementsByTagName(nomeTagSaidaPocos);
  			int numeroPocosEncontrados = 0;
  			int numeroTagsEncontradas = 0;
  			for (int temp = 0; temp < nList.getLength(); temp++){
  				Node node = nList.item(temp);
  				if (node.getNodeType() == Node.ELEMENT_NODE){
  					Element eElement = (Element) node;
  					String nomePoco = eElement.getAttribute("name");
  					if(nomePoco.equalsIgnoreCase(poco)) {
  						numeroPocosEncontrados++;
  						for (String s : listaInformacoesSaidaPoco) {
  							if (s.equalsIgnoreCase(tag)){
  								numeroTagsEncontradas++;
  								retorno = Double.parseDouble(eElement.getElementsByTagName(s).item(0).getTextContent());
  							}
  						}
  					}
  				}
  			}
  			if(numeroPocosEncontrados == 0) {
  				return -1.0;
  			}
  			if(numeroTagsEncontradas == 0) {
  				return -2.0;
  			}
  		}
  		return retorno;
  	}
}
