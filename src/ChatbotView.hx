package;

import haxe.ui.focus.FocusManager;
import haxe.ui.util.Color;
import haxe.ui.util.Timer;
import haxe.ui.core.Component;
import haxe.Json;
import haxe.ui.ToolkitAssets;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Button;

@:build(haxe.ui.ComponentBuilder.build("assets/ChatbotView.xml"))
class ChatbotView extends VBox {
	var loadQDelay = 1000;
	var loadADelay = 100;
	var componentsToAdd:Array<CTA> = [];
	var running:Bool = false;
	var idcount = 0;
	var json:Comment;

	public function new() {
		super();
		/*
			this.top=100;
			this.left=100;
		 */
		json = Json.parse(ToolkitAssets.instance.getText("res/chatbot.json"));
		loadSection(json);
		// createTree(json);
	}

	/*
			function createTree(node:Comment, parent = null) {
				var n = tree.addNode(node.text.join("\n"));
				if (node.buttons.length > 0) {
					for (d in node.buttons)
						createFolder(d, n);
				}
			}
		 
		function createFolder(btn:Button, parent) {
			var b = tree.addNode(btn.text);
			//for (c in btn)
			//	createTree(b.comm) }

	 */
	function loadSection(data:Comment) {
		var loadQuestionDelay = Math.floor(Math.random() * 1000) + loadQDelay;
		for (q in data.text) {
			var question = new Question(data);
			if (data.qid != null)
				question.id = data.qid;
			else
				question.id = 'q${idcount++}';
			question.question.text = q;

			addComponentWithDelay(question, loadQuestionDelay);
		}
		var answerList:Array<Answer> = [];
		for (b in data.buttons) {
			var answer = new Answer();
			answerList.push(answer);
			answer.answer.text = b.text;
			answer.answer.onClick = (e) -> {
				if (b.comment != null) {
					answer.sending.text = "Sending...";
					answer.sending.show();
					Timer.delay(() -> {
						var time = Date.now();
						answer.sending.text = 'Delivered ${time.getHours()}:${time.getMinutes()}';
						loadSection(b.comment);
						Timer.delay(() -> {
							answer.sending.hide();
						}, loadQuestionDelay);
					}, 500);

					for (a in answerList)
						if (a != answer) {
							a.hide();
						} else {
							a.answer.disabled = true;
							a.answer.backgroundColor = a.answer.borderColor;
							a.answer.opacity = 1;
							#if !hl
							a.answer.color = Color.fromString("#ffffff");
							#end
						}
				} else if (b.link != null) {
					if (b.link.substr(0, 8) == "https://") {
						#if js
						// js.Browser.document.location.href=b.link;
						// js.Browser.window.open(b.link, "_blank");
						// loadSection(cast(this.findComponent("q1"),Question).comment);
						#end
					} else {
						loadSection(cast(this.findComponent(b.link), Question).comment);
					}
				}
			}
			addComponentWithDelay(answer, loadADelay);
		}
	}

	function addComponentWithDelay(c, delay) {
		componentsToAdd.push({component: c, time: delay});
		if (!running)
			addTheComponent();
	}

	function addTheComponent() {
		if (componentsToAdd.length > 0) {
			var next = componentsToAdd[0];
			chatArea.addComponent(componentsToAdd.shift().component);
			chatAreaScroll.vscrollPos = chatAreaScroll.vscrollMax + chatAreaScroll.height; // TODO: use focusmanager?
			if (next != null) {
				running = true;
				Timer.delay(() -> {
					var balls = next.component.findComponent("balls");
					if (balls != null) {
						next.component.findComponent("balls").hide();
						next.component.findComponent("question").show();
					}
					addTheComponent();
				}, next.time);
			}
		} else {
			running = false;
		}
	}
	/*
		@:bind(button2, MouseEvent.CLICK)
		private function onMyButton(e:MouseEvent) {
			button2.text = "Thanks!";
	}*/
}

typedef CTA = {
	var component:Component;
	var time:Int;
}

typedef Comment = {
	var text:Array<String>;
	var buttons:Array<Buttons>;
	var ?qid:String;
}

typedef Buttons = {
	text:String,
	comment:Comment,
	siblings:Array<Component>,
	?link:String,
}
