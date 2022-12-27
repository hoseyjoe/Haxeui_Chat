package;

import haxe.ui.containers.HBox;

@:build(haxe.ui.macros.ComponentMacros.build("assets/Question.xml"))
class Question extends HBox {
	public var comment:ChatbotView.Comment;

	public function new(com:ChatbotView.Comment) {
		super();
		comment = com;
	}
}
