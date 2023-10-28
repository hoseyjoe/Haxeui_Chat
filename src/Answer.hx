package;

import ChatbotView.Comment;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;

@:xml('<vbox width="100%">
    <style>
        #answer:hover{
            background-color:#CCD9EE
        }
    </style>
    <button id="answerbtn" text="hello" horizontalAlign="right" style="border-radius:5; border-size:2px; border-color:#1C63B8;padding:5"></button>
    <vbox id="wrapper" width="100%"  style="border-radius:5; border-size:2px; border-color:#1C63B8;padding:5" horizontalAlign="right" hidden="true">
        <label id="answerlabel" text="" width="100%" style="text-align:right"/>
        <hbox width="100%">
            <textfield id="entry" width="100%" text="" /><button id="answerBtnEntry" text=">"/>
        </hbox>
    </vbox>
    <label id="sending" hidden="true" text="Sending..." horizontalAlign="right" style="font-size:8px"></label>
</vbox>')	

class Answer extends VBox{

    public function new() {
        super();

    }
}