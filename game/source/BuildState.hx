package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.system.FlxSound;

using flixel.util.FlxSpriteUtil;

private class PickupCaller
{
    private var component:Component;
    private var player:Player;
	private var click:FlxSound;
    public function new(player:Player, component:Component)
    {
        this.component = component;
        this.player = player;
		this.click = FlxG.sound.load(AssetPaths.click__wav);
    }

    public function clickFn()
    {
		this.click.play();
        if (player.getCarrying() == component)
        {
            player.drop();
            Deb.trace('dropped ${component.getName()}');
        }
        else
        {
            player.pickup(component);
            Deb.trace('picked up ${component.getName()}');
        }
    }
}

private class ShipCaller
{
    private var player:Player;
    private var spot:Int;
	private var cancel:FlxSound;
	private var click:FlxSound;
    public function new(player:Player, spot:Int)
    {
        this.player = player;
        this.spot = spot;
		this.cancel = FlxG.sound.load(AssetPaths.cancel__wav);
		this.click = FlxG.sound.load(AssetPaths.click__wav);
    }

    public function clickFn()
    {
        var component:Component = player.getCarrying();
		var previousComponent:Component = player.getShip().getComponent(spot);
		player.sellComponent(spot);
		Deb.trace('Sold component ${previousComponent.getName()} in spot $spot');
        if (component != Ship.emptyComponent)
        {
			this.click.play();
            player.buyComponent(spot);
            Deb.trace('Bought component ${component.getName()} in spot $spot');
        }
		else
		{
			this.cancel.play();
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

private class ComponentText extends FlxText
{
    public function new(x:Int, y:Int, text:String, w:Int = 32*16)
    {
        super(x, y, w);
        this.setFormat("assets/fonts/font.ttf", 20, FlxColor.WHITE, "left");
        this.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.RED, 1);
        this.text = text;
    }
}

/**
 * A FlxState which can be used for the game's menu.
 */
class BuildState extends FlxUIState
{
    // Player manager/finances/ship/...
    static var ship = new Ship();
    static var player = new Player(10 /*initialMoney*/, ship);

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
    private var slot3:FlxButton;
    private var slot4:FlxButton;
	
	private var helpButton:FlxButton;
	private var returnFromHelp:FlxButton;
	private var helpActive:Bool;

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
	
	private var goSoundEffect:FlxSound;

    private var enginel1Text:ComponentText;
    private var enginel2Text:ComponentText;
    private var enginel3Text:ComponentText;
    private var turretl1Text:ComponentText;
    private var turretl2Text:ComponentText;
    private var shieldText:ComponentText;
    private var cargoText:ComponentText;

	private function goFn() {
		this.goSoundEffect.play();
		var cptLog = player.goMission();
        var logState = new CaptainLogState(cptLog);
        FlxG.switchState(logState);
	}
    private var btnGo:FlxButton;
    inline static var componentXOffset = 35;
    inline static var componentYOffset = 5;

	private function helpButtonPressed():Void {
		this.helpActive = true;
		destroyButtons();
		this.returnFromHelp = new FlxButton(0, 0, "", leaveHelp);
		this.returnFromHelp.loadGraphic("assets/gfx/sprites/help.png", false, 640, 480, false);
		add(this.returnFromHelp);
	}
	
	private function leaveHelp():Void {
		this.helpActive = false;
		this.returnFromHelp.destroy();
		createButtons();
	}
	
	private function createButtons():Void {
		this.helpButton = new FlxButton(352, 416, "", helpButtonPressed);
		this.helpButton.loadGraphic("assets/gfx/sprites/help_button.png", false, 96, 32, false);
		add(this.helpButton);
		
		// Engines
        _btnEnginel1 = new FlxButton(384, 65, "", new PickupCaller(player, enginel1).clickFn);
        _btnEnginel1.loadGraphic("assets/gfx/sprites/enginel1.png", false, 32, 32, false);
        add(_btnEnginel1);
        enginel1Text = new ComponentText(
            384+componentXOffset,
            65+componentYOffset,
            '${enginel1.summary()}');
        add(enginel1Text);

        _btnEnginel2 = new FlxButton(384, 97, "", new PickupCaller(player, enginel2).clickFn);
        _btnEnginel2.loadGraphic("assets/gfx/sprites/enginel2.png", false, 32, 32, false);
        add(_btnEnginel2);
        enginel2Text = new ComponentText(
            384+componentXOffset,
            97+componentYOffset,
            '${enginel2.summary()}');
        add(enginel2Text);

        _btnEnginel3 = new FlxButton(384, 129, "", new PickupCaller(player, enginel3).clickFn);
        _btnEnginel3.loadGraphic("assets/gfx/sprites/enginel3.png", false, 32, 32, false);
        add(_btnEnginel3);
        enginel3Text = new ComponentText(
            384+componentXOffset, 
            129+componentYOffset,
            '${enginel3.summary()}');
        add(enginel3Text);

        // Turrets
        _btnTurretl1 = new FlxButton(384, 191, "", new PickupCaller(player, turretl1).clickFn);
        _btnTurretl1.loadGraphic("assets/gfx/sprites/turretl1.png", false, 32, 32, false);
        add(_btnTurretl1);
        turretl1Text = new ComponentText(
            384+componentXOffset, 
            191+componentYOffset,
            '${turretl1.summary()}');
        add(turretl1Text);

        _btnTurretl2 = new FlxButton(384, 223, "", new PickupCaller(player, turretl2).clickFn);
        _btnTurretl2.loadGraphic("assets/gfx/sprites/turretl2.png", false, 32, 32, false);
        add(_btnTurretl2);
        turretl2Text = new ComponentText(
            384+componentXOffset, 
            223+componentYOffset,
            '${turretl2.summary()}');
        add(turretl2Text);

        // Shield
        _btnShield = new FlxButton(384, 287, "", new PickupCaller(player, shield).clickFn);
        _btnShield.loadGraphic("assets/gfx/sprites/shield.png", false, 32, 32, false);
        add(_btnShield);
        shieldText = new ComponentText(
            384+componentXOffset, 
            287+componentYOffset,
            '${shield.summary()}');
        add(shieldText);

        // Cargo
        _btnCargo = new FlxButton(384, 319, "", new PickupCaller(player, cargo).clickFn);
        _btnCargo.loadGraphic("assets/gfx/sprites/cargo.png", false, 32, 32, false);
        add(_btnCargo);
        cargoText = new ComponentText(
            384+componentXOffset, 
            319+componentYOffset,
            '${cargo.summary()}');
        add(cargoText);
		
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
		
        slot3 = new FlxButton(192, 159, "", new ShipCaller(player, 3).clickFn);
        slot3.loadGraphic("assets/gfx/sprites/empty.png", false, 32, 32, false);
        add(slot3);

        slot4 = new FlxButton(192, 223, "", new ShipCaller(player, 4).clickFn);
        slot4.loadGraphic("assets/gfx/sprites/empty.png", false, 32, 32, false);
        add(slot4);

        // Go
        btnGo = new FlxButton(480, 415, "", goFn);
        btnGo.height = 32;
        btnGo.width = 128;
        btnGo.loadGraphic("assets/gfx/sprites/go.png");
        add(btnGo);
	}
	
	private function destroyButtons():Void {
		btnGo.destroy();
		helpButton.destroy();
		slot0.destroy();
		slot1.destroy();
		slot2.destroy();
		slot3.destroy();
		slot4.destroy();
		
		_btnShield.destroy();
		_btnCargo.destroy();
		_btnTurretl1.destroy();
		_btnTurretl2.destroy();
		_btnEnginel1.destroy();
		_btnEnginel2.destroy();
		_btnEnginel3.destroy();
	}
	
    /**
     * Function that is called up when to state is created to set it up.
     */
    override public function create():Void
    {
		this.goSoundEffect = FlxG.sound.load(AssetPaths.go__wav);
		this.helpActive = false;
		
        // Components
        enginel1 = new Component(-1,0,2,0,1,"enginel1");
        enginel2 = new Component(-1,0,5,0,3,"enginel2");
        enginel3 = new Component(-3,0,10,0,8,"enginel3");

        turretl1 = new Component(0,3,0,0,1,"turretl1");
        turretl2 = new Component(0,6,0,0,4,"turretl2");

        shield = new Component(1,0,0,0,1,"shield", "shield");
        cargo = new Component(0,0,0,1,1,"cargo", "cargo");

        // GUI buttons
        _xml_id = "state_build";

		createButtons();
		
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
        var comp3 = ship.getComponent(3).getName();
        var comp4 = ship.getComponent(4).getName();
		if (this.helpActive == false)
		{
			slot0.loadGraphic('assets/gfx/sprites/${comp0 != "" ? comp0 : "empty"}.png', false, 32, 32, false);
			slot1.loadGraphic('assets/gfx/sprites/${comp1 != "" ? comp1 : "empty"}.png', false, 32, 32, false);
			slot2.loadGraphic('assets/gfx/sprites/${comp2 != "" ? comp2 : "empty"}.png', false, 32, 32, false);
			slot3.loadGraphic('assets/gfx/sprites/${comp3 != "" ? comp3 : "empty"}.png', false, 32, 32, false);
			slot4.loadGraphic('assets/gfx/sprites/${comp4 != "" ? comp4 : "empty"}.png', false, 32, 32, false);
		}

		statHP.text = '${ship.getHp()}';
		statAtk.text = '${ship.getAttack()}';
		statDef.text = '${ship.getDefense()}';
		statSpd.text = '${ship.getSpeed()}';
		statCarg.text = '${ship.getCargo()}';
		statCur.text = '${player.getMoney()}';
        super.update();
    }
}
