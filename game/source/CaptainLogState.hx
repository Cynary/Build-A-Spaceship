package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.ui.FlxButton;

class CaptainLogState extends FlxState {
	private var cptLog: CaptainLog;

    public function new(cptLog:CaptainLog) {
    	super();
    	this.cptLog = cptLog;
    }

    override public function create():Void {
		var soundEffect = FlxG.sound.load(AssetPaths.go__wav);
		soundEffect.play();
    	var sprite = this.cptLog.createSprite(640-100, 480-100, 50, 50);
    	add(sprite);
    	function goToBuild() {
    		FlxG.switchState(new BuildState());
    	}
    	add(new FlxButton(50, 480-50, "continue", goToBuild));
    }
}
