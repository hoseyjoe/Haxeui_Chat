package;

import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;

class Chatbot {
	public static function main() {
		var app = new HaxeUIApp();
		// Toolkit.theme = "joedark"; // TODO DO stuff
		// LocaleManager.instance.language = "en";
		app.ready(function() {
			app.addComponent(new ChatbotView());

			app.start();
		});
	}
}
