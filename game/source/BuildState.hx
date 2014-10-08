package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

private class PickupCaller
{
    private var component:Component;
    private var player:Player;
    public function new(player:Player, component:Component)
    {
        this.component = component;
        this.player = player;
    }

    public function clickFn()
    {
        if (player.getCarrying() == component)
        {
            player.drop();
            trace('dropped ${component.getName()}');
        }
        else
        {
            player.pickup(component);
            trace('picked up ${component.getName()}');
        }
    }
}

private class ShipCaller
{
    private var player:Player;
    private var spot:Int;
    public function new(player:Player, spot:Int)
    {
        this.player = player;
        this.spot = spot;
    }

    public function clickFn()
    {
        var component:Component = player.getCarrying();
		var previousComponent:Component = player.getShip().getComponent(spot);
		player.sellComponent(spot);
		trace('Sold component ${previousComponent.getName()} in spot $spot');
        if (component != Ship.emptyComponent)
        {
            player.buyComponent(spot);
            trace('Bought component ${component.getName()} in spot $spot');
        }
    }
}

private class StatText extends FlxText
{
    public function new(x:Int, y:Int, w:Int, text:String)
    {
        super(x, y, w);
        this.setFormat("assets/fonts/font.ttf", 20, FlxColor.WHITE, "center");
        this.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.RED, 1);
        this.text = text;
    }
}

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

    private var slot0:FlxButton;
    private var slot1:FlxButton;
    private var slot2:FlxButton;

    private var ship:Ship;
    private var player:Player;
    private var enginel1:Component;
    private var enginel2:Component;
    private var enginel3:Component;
    private var turretl1:Component;
    private var turretl2:Component;
    private var shield:Component;
    private var cargo:Component;

    private var statHP:StatText;
    private var statAtk:StatText;
    private var statDef:StatText;
    private var statSpd:StatText;
    private var statCarg:StatText;
    private var statCur:StatText;

	private function goFn() {
		var sprite = player.goMission();
		add(sprite);
	}

    /**
     * Function that is called up when to state is created to set it up.
     */
    override public function create():Void
    {
        // Player manager/finances/ship/...
        ship = new Ship();
        player = new Player(10 /*initialMoney*/, ship);

        // Components
        enginel1 = new Component(-1,0,2,0,1,"enginel1");
        enginel2 = new Component(-1,0,5,0,3,"enginel2");
        enginel3 = new Component(-3,0,10,0,8,"enginel3");

        turretl1 = new Component(0,3,0,0,1,"turretl1");
        turretl2 = new Component(0,6,0,0,4,"turretl2");

        shield = new Component(1,0,0,0,1,"shield");
        cargo = new Component(0,0,0,1,1,"cargo");

        // GUI buttons
        _xml_id = "state_build";

        // Engines
        _btnEnginel1 = new FlxButton(384, 65, "", new PickupCaller(player, enginel1).clickFn);
        _btnEnginel1.loadGraphic("assets/gfx/sprites/enginel1.png", false, 32, 32, false);
        add(_btnEnginel1);

        _btnEnginel2 = new FlxButton(384, 97, "", new PickupCaller(player, enginel2).clickFn);
        _btnEnginel2.loadGraphic("assets/gfx/sprites/enginel2.png", false, 32, 32, false);
        add(_btnEnginel2);

        _btnEnginel3 = new FlxButton(384, 129, "", new PickupCaller(player, enginel3).clickFn);
        _btnEnginel3.loadGraphic("assets/gfx/sprites/enginel3.png", false, 32, 32, false);
        add(_btnEnginel3);

        // Turrets
        _btnTurretl1 = new FlxButton(384, 191, "", new PickupCaller(player, turretl1).clickFn);
        _btnTurretl1.loadGraphic("assets/gfx/sprites/turretl1.png", false, 32, 32, false);
        add(_btnTurretl1);

        _btnTurretl2 = new FlxButton(384, 223, "", new PickupCaller(player, turretl2).clickFn);
        _btnTurretl2.loadGraphic("assets/gfx/sprites/turretl2.png", false, 32, 32, false);
        add(_btnTurretl2);

        // Shield
        _btnShield = new FlxButton(384, 287, "", new PickupCaller(player, shield).clickFn);
        _btnShield.loadGraphic("assets/gfx/sprites/shield.png", false, 32, 32, false);
        add(_btnShield);

        // Cargo
        _btnCargo = new FlxButton(384, 319, "", new PickupCaller(player, cargo).clickFn);
        _btnCargo.loadGraphic("assets/gfx/sprites/cargo.png", false, 32, 32, false);
        add(_btnCargo);

        // Extra canvas things
        var canvas = new FlxSprite();
        canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        add(canvas);


        // Stats
        statHP = new StatText(40, 355, 32, '${ship.getHp()}');
        add(statHP);

        statDef = new StatText(90, 355, 32, '${ship.getAttack()}');
        add(statDef);

        statAtk = new StatText(140, 355, 32, '${ship.getDefense()}');
        add(statAtk);

        statSpd = new StatText(190, 355, 32, '${ship.getSpeed()}');
        add(statSpd);

        statCarg = new StatText(240, 355, 32, '${ship.getCargo()}');
        add(statCarg);

        statCur = new StatText(283, 355, 32, '${player.getMoney()}');
        add(statCur);


        // Ship slots
        slot0 = new FlxButton(128, 191, "", new ShipCaller(player, 0).clickFn);
        slot0.loadGraphic("assets/gfx/sprites/empty.png", false, 32, 32, false);
        add(slot0);

        slot1 = new FlxButton(160, 191, "", new ShipCaller(player, 1).clickFn);
        slot1.loadGraphic("assets/gfx/sprites/empty.png", false, 32, 32, false);
        add(slot1);

        slot2 = new FlxButton(192, 191, "", new ShipCaller(player, 2).clickFn);
        slot2.loadGraphic("assets/gfx/sprites/empty.png", false, 32, 32, false);
        add(slot2);

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
        var comp0 = ship.getComponent(0).getName();
        var comp1 = ship.getComponent(1).getName();
        var comp2 = ship.getComponent(2).getName();
        slot0.loadGraphic('assets/gfx/sprites/${comp0 != "" ? comp0 : "empty"}.png', false, 32, 32, false);
        slot1.loadGraphic('assets/gfx/sprites/${comp1 != "" ? comp1 : "empty"}.png', false, 32, 32, false);
        slot2.loadGraphic('assets/gfx/sprites/${comp2 != "" ? comp2 : "empty"}.png', false, 32, 32, false);

		statHP.text = '${ship.getHp()}';
		statAtk.text = '${ship.getAttack()}';
		statDef.text = '${ship.getDefense()}';
		statSpd.text = '${ship.getSpeed()}';
		statCarg.text = '${ship.getCargo()}';
		statCur.text = '${player.getMoney()}';
        super.update();
    }
}
