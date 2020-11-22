// CArtAgO artifact code for project chatbot_jacamo
package tools;

import cartago.*;
import java.io.File;
import org.alicebot.ab.AB;
import org.alicebot.ab.Bot;
import org.alicebot.ab.Chat;
import org.alicebot.ab.History;
import org.alicebot.ab.MagicBooleans;
import org.alicebot.ab.MagicStrings;
import org.alicebot.ab.PCAIMLProcessorExtension;
import org.alicebot.ab.utils.IOUtils;

public class Graphmaster extends Artifact {
	private static final boolean TRACE_MODE = false;
	static String botName = "super";
	private Chat chatSession;
	private Bot bot;

	void init() {
		String resourcesPath = getResourcesPath();
		System.out.println(resourcesPath);
		MagicBooleans.trace_mode = TRACE_MODE;
		org.alicebot.ab.AIMLProcessor.extension = new PCAIMLProcessorExtension();
		bot = new Bot(botName, resourcesPath);
		bot.writeAIMLFiles();
		chatSession = new Chat(bot);
		AB.ab(bot);
	}

	private static String getResourcesPath() {
			File currDir = new File(".");
			String path = currDir.getAbsolutePath();
			path = path.substring(0, path.length() - 2);
			System.out.println(path);
			String resourcesPath = path + File.separator + "src" + File.separator + "resources";
			return resourcesPath;
	}

	@OPERATION
	void calculaResposta(Object entrada, OpFeedbackParam<String> saida) {
		String entradaStr = entrada.toString();
		String resposta = "";

		if ((entradaStr == null) || (entradaStr.length() < 1))
			entradaStr = MagicStrings.null_input;
			if (entradaStr.equals("q")) {
				System.exit(0);
			} else if (entradaStr.equals("wq")) {
				bot.writeQuit();
				System.exit(0);
			} else {
				String request = entradaStr;
				if (MagicBooleans.trace_mode)
					System.out.println("STATE=" + request + ":THAT=" + ((History) chatSession.thatHistory.get(0)).get(0) + ":TOPIC=" + chatSession.predicates.get("topic"));
				resposta = chatSession.multisentenceRespond(request);
				while (resposta.contains("&lt;"))
					resposta = resposta.replace("&lt;", "<");
				while (resposta.contains("&gt;"))
					resposta = resposta.replace("&gt;", ">");
				//System.out.println("Robot : " + resposta);
			}
		saida.set(resposta);
	}
}
