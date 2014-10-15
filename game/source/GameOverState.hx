package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class GameOverState extends FlxState
{
	var gameOverText:FlxText;
	var text:String;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */

	 public function new(text:String) {
    	super();
    	this.text  = text;
    }

	override public function create():Void
	{
		this.gameOverText = new FlxText(10, 10, 100);
		this.gameOverText.text = text;
		add(this.gameOverText);
		super.create();
	}
	
	// private function startGame():Void
	// {
	// 	FlxG.switchState(new BuildState());
	// }
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		this.gameOverText.destroy();
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}