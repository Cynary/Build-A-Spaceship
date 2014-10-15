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
class TitleState extends FlxState
{
	private var titleButton:FlxButton;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		this.titleButton = new FlxButton(0, 0, "", startGame);
		this.titleButton.loadGraphic("assets/gfx/sprites/title.png", false, 640, 480, false);
		add(this.titleButton);
		super.create();
	}
	
	private function startGame():Void
	{
		FlxG.switchState(new BuildState());
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		this.titleButton.destroy();
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