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
import flixel.plugin.MouseEventManager;

using flixel.util.FlxSpriteUtil;

private class StatText extends FlxText
{
    public function new(x:Int, y:Int, w:Int, text:String)
    {
        super(x, y, w);
        this.setFormat("assets/fonts/font.ttf", 20, FlxColor.WHITE, "center");
        this.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.BLACK, 1);
        this.text = text;
    }
}

private class ComponentText extends FlxText
{
    public function new(x:Int, y:Int, text:String, w:Int = 32*16)
    {
        super(x, y, w);
        this.setFormat("assets/fonts/font.ttf", 20, FlxColor.WHITE, "left");
        this.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.BLACK, 1);
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

    private var carryingSprite:FlxSprite;
    private var pickupSound:FlxSound;
    private var cancelSound:FlxSound;

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

    private var missionCounter:StatText;
	
	private var goSoundEffect:FlxSound;

    private var enginel1Text:ComponentText;
    private var enginel2Text:ComponentText;
    private var enginel3Text:ComponentText;
    private var turretl1Text:ComponentText;
    private var turretl2Text:ComponentText;
    private var shieldText:ComponentText;
    private var cargoText:ComponentText;

	private function goFn() {
		//this.goSoundEffect.play();
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
	
    private function createButton(component:Component, x:Int, y:Int, asset:String, text:String):FlxButton {
        var button:FlxButton = new FlxButton(x, y, "");
        button.loadGraphic(asset, false, 32, 32, false);
        var state:FlxUIState = this;
        button.onDown.callback = function() {
            // Picking up happens here
            if (carryingSprite == null) {
                pickupSound.play();
                player.pickup(component);
                carryingSprite = new FlxSprite(FlxG.mouse.x - 16, FlxG.mouse.y - 16);
                carryingSprite.loadGraphic(asset, false, 32, 32, false);
                state.add(carryingSprite);
                player.pickup(component);
            }
        };
        add(button);
        var componentText:ComponentText = new ComponentText(
            x+componentXOffset,
            y+componentYOffset,
            text);
        add(componentText);
        return button;
    }

    private function createShipSlot(x:Int, y:Int, spot:Int):FlxButton {
        var slot:FlxButton = new FlxButton(x, y, "");
        slot.loadGraphic("assets/gfx/sprites/empty.png", false, 32, 32, false);
        var state:BuildState = this;
        slot.onDown.callback = function() {
            if (carryingSprite == null) {
                state.cancelSound.play();
                player.sellComponent(spot);
            }
        };
        slot.onUp.callback = function() {
            if (carryingSprite != null) {
                state.pickupSound.play();
                player.sellComponent(spot);
                player.buyComponent(spot);
            }
        };
        add(slot);
        return slot;
    }

	private function createButtons():Void {
		this.helpButton = new FlxButton(352, 416, "", helpButtonPressed);
		this.helpButton.loadGraphic("assets/gfx/sprites/help_button.png", false, 96, 32, false);
		add(this.helpButton);

        // Load sound
        pickupSound = FlxG.sound.load(AssetPaths.click__wav);
        cancelSound = FlxG.sound.load(AssetPaths.cancel__wav);
		
		// Engines
        _btnEnginel1 = createButton(enginel1, 384, 65, "assets/gfx/sprites/enginel1.png", '${enginel1.summary()}');
        _btnEnginel2 = createButton(enginel2, 384, 97, "assets/gfx/sprites/enginel2.png", '${enginel2.summary()}');
        _btnEnginel3 = createButton(enginel3, 384, 129,"assets/gfx/sprites/enginel3.png", '${enginel3.summary()}');

        // Turrets
        _btnTurretl1 = createButton(turretl1, 384, 191, "assets/gfx/sprites/turretl1.png", '${turretl1.summary()}');
        _btnTurretl2 = createButton(turretl2, 384, 223, "assets/gfx/sprites/turretl2.png", '${turretl2.summary()}');

        // Shield
        _btnShield = createButton(shield, 384, 287, "assets/gfx/sprites/shield.png", '${shield.summary()}');

        // Cargo
        _btnCargo = createButton(cargo, 384, 319, "assets/gfx/sprites/cargo.png", '${cargo.summary()}');
		
        // Ship slots
        slot0 = createShipSlot(128, 191, 0);
        slot1 = createShipSlot(160, 191, 1);
        slot2 = createShipSlot(192, 191, 2);
        slot3 = createShipSlot(192, 159, 3);
        slot4 = createShipSlot(192, 223, 4);

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
		
        // Extra canvas things
        var canvas = new FlxSprite();
        canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        add(canvas);
		
        super.create();
		
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

        missionCounter = new StatText(55, 415, 250, 'Current mission: ${player.getMissionNumber()+1}');
        add(missionCounter);
		
		createButtons();
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
        if (player.getMoney() < 0)
        {
            FlxG.switchState(new GameOverState("Out of Money! You Lose!"));
        }

        if (player.getMissionNumber() == 6)
        {
            FlxG.switchState(new GameOverState("You've completed all your missions. You win with $" +player.getMoney() + "!"));
        }
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
        missionCounter.text = 'Current mission: ${player.getMissionNumber()+1}';

        if (carryingSprite != null) {
            carryingSprite.setPosition(FlxG.mouse.x-16,FlxG.mouse.y-16);
            if (FlxG.mouse.justReleased) {
                remove(carryingSprite);
                carryingSprite = null;
                player.drop();
            }
        }

        super.update();
    }
}
