package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxDestroyUtil;

/**
 * A FlxState which can be used for the game's menu.
 */
class BuildState extends FlxUIState
{
    private var _btnShield:FlxButton;
    private var _btnCargo:FlxButton;
    private var _btnTurretl1:FlxButton;
    private var _btnTurretl2:FlxButton;
    private var _btnEnginel1:FlxButton;
    private var _btnEnginel2:FlxButton;
    private var _btnEnginel3:FlxButton;

    private function clickShield():Void
    {
        trace("clicked shield");
    }

    private function clickCargo():Void
    {
        trace("clicked cargo");
    }

    private function clickTurretl1():Void
    {
        trace("clicked turretl1");
    }

    private function clickTurretl2():Void
    {
        trace("clicked turretl2");
    }

    private function clickEnginel1():Void
    {
        trace("clicked enginel1");
    }

    private function clickEnginel2():Void

    {
        trace("clicked enginel2");
    }

    private function clickEnginel3():Void
    {
        trace("clicked enginel3");
    }

    /**
     * Function that is called up when to state is created to set it up.
     */
    override public function create():Void
    {
        _xml_id = "state_build";

        // Engines
		_btnEnginel1 = new FlxButton(384, 65, "", clickEnginel1);
		_btnEnginel1.loadGraphic("assets/gfx/sprites/enginel1.png", false, 32, 32, false);
        add(_btnEnginel1);

		_btnEnginel2 = new FlxButton(384, 97, "", clickEnginel2);
		_btnEnginel2.loadGraphic("assets/gfx/sprites/enginel2.png", false, 32, 32, false);
        add(_btnEnginel2);

		_btnEnginel3 = new FlxButton(384, 129, "", clickEnginel3);
		_btnEnginel3.loadGraphic("assets/gfx/sprites/enginel3.png", false, 32, 32, false);
        add(_btnEnginel3);

        // Turrets
		_btnTurretl1 = new FlxButton(384, 191, "", clickTurretl1);
		_btnTurretl1.loadGraphic("assets/gfx/sprites/turretl1.png", false, 32, 32, false);
        add(_btnTurretl1);

		_btnTurretl2 = new FlxButton(384, 223, "", clickTurretl2);
		_btnTurretl2.loadGraphic("assets/gfx/sprites/turretl2.png", false, 32, 32, false);
        add(_btnTurretl2);

        // Shield
		_btnShield = new FlxButton(384, 287, "", clickShield);
		_btnShield.loadGraphic("assets/gfx/sprites/shield.png", false, 32, 32, false);
        add(_btnShield);

        // Cargo
		_btnCargo = new FlxButton(384, 319, "", clickCargo);
		_btnCargo.loadGraphic("assets/gfx/sprites/cargo.png", false, 32, 32, false);
        add(_btnCargo);

        super.create();
    }

    /**
     * Function that is called when this state is destroyed - you might want to
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy():Void
    {
        _btnShield = FlxDestroyUtil.destroy(_btnShield);
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
