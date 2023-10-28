package;

import http.HttpError;
import http.HttpClient;
import haxe.ui.focus.FocusManager;
import haxe.ui.util.Color;
import haxe.ui.util.Timer;
import haxe.ui.core.Component;
import haxe.Json;
import haxe.ui.ToolkitAssets;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Button;

@:xml('<vbox style="padding: 1px;width:300px;height:500px; spacing:0; ">
    <style>

    </style>
    <hbox width="100%" id="header" style="padding:5 10 10 5; border-top-left-radius:10px; border-top-right-radius:10px; background: #3870E0; ">
        <image id="theIcon" resource="haxeui-core/styles/default/haxeui_small.png"/>
        <label width="100%" verticalAlign="center" text="HoseyJoe" style="color:white;"/>
        <button text="X" id="XXX" verticalAlign="center" style="padding:0;background-opacity:0; border:none;color:white;"/>
    </hbox>
    <scrollview id="chatAreaScroll" width="100%" height="100%" contentWidth="100%" style="border:1px solid gray">
        <vbox id="chatArea" width="100%" style="background: white;padding:5;">

        </vbox>
    </scrollview>
    <hbox width="100%" id="footer" style="padding:5 10 10 5; border-bottom-left-radius:10px; border-bottom-right-radius:10px; background: #DDDDDD; ">
        <label width="100%" verticalAlign="center" text="Powered by HoseyJoe" style="text-align:right"/>
    </hbox>
</vbox>')
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
		trace(data);
		for (q in data.questiontext) {
			var question = new Question(data);
			if (data.qid != null)
				question.id = data.qid;
			else
				question.id = 'q${idcount++}';
			question.question.text = q;
			
			addComponentWithDelay(question, loadQuestionDelay);
		}
		var answerList:Array<Answer> = [];
		if (data.buttons!=null)
		for (b in data.buttons) {
			var answer = new Answer();
			answerList.push(answer);
			if (b.questionfield!=null){
				answer.answerlabel.text = b.buttontext;
				answer.entry.placeholder = b.questionfield;
			}else{
				answer.answerbtn.text = b.buttontext;
			}
			
			if (b.questionfield != ''){
				if (answer != null && answer.entry!=null){
					answer.entry.hidden=false;
					answer.entry.placeholder="IDK";
				}
			}
			answer.answerBtnEntry.onClick=answer.answerbtn.onClick = (e) -> {
				if (answer.entry.text!=""){
					var client:HttpClient = new HttpClient();
					client.retryCount = 2;
					client.get('http://localhost/answer.text').then(result -> {
						trace(result);
					}, (error:HttpError) -> {
						// error   
					});
					
				}
				if (b.comment != null) {
					answer.sending.text = "Sending...";
					answer.sending.show();
					Timer.delay(() -> {
						var time = Date.now();
						answer.sending.text = 'Delivered ${time.getHours()}:${time.getMinutes()}';
						trace(b.comment);
						loadSection(b.comment);
						Timer.delay(() -> {
							answer.sending.hide();
						}, loadQuestionDelay);
					}, 500);

					for (a in answerList)
						if (a != answer) {
							a.hide();
						} else {
							a.answerbtn.disabled = true;
							a.answerbtn.backgroundColor = a.answerbtn.borderColor;
							a.answerbtn.opacity = 1;
							#if !hl
							a.answerbtn.color = Color.fromString("#ffffff");
							#end
						}
				} else if (b.link != null) {
					if (b.link.substr(0, 8) == "https://") {
						#if js
						//js.Browser.document.location.href=b.link;
						js.Browser.window.open(b.link, "_blank");
						// loadSection(cast(this.findComponent("q1"),Question).comment);
						#end
					} else {
						trace(cast(this.findComponent(b.link), Question).comment);
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
			//trace(Type.getClass(next.component)== Answer);
			//trace(Type.getClass(next.component)==Question);
			chatArea.addComponent(componentsToAdd.shift().component);
			chatAreaScroll.vscrollPos = chatAreaScroll.vscrollMax + chatAreaScroll.height; // TODO: use focusmanager?
			if (next != null) {
				running = true;
				Timer.delay(() -> {
					var balls = next.component.findComponent("balls");
					if (balls != null) {//questions
						balls.hide();
						next.component.findComponent("question").show();
							
					}else{//answers
						if ((Type.getClass(next.component) == Answer)) {
							var answer:Answer = cast next.component;
							//answer..show();
							if (answer.answerlabel.text != "") {
								answer.wrapper.show();
								answer.answerbtn.hide();
							} else {
								answer.wrapper.hide();
								answer.answerbtn.show();
							}
						}else{
							trace(next.component.id);
						}
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
	var questiontext:Array<String>;
	var buttontext:Array<String>;
	var buttons:Array<Buttons>;
	var ?qid:String;
}

typedef Buttons = {
	buttontext:String,
	questionfield:String,
	comment:Comment,
	siblings:Array<Component>,
	?link:String,
}
