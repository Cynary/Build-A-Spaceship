package;

class Ship
{
	// Layout
	//
	private var nSpots:Int;
	private var components:Array<Component>;

	private var hp:Int;
	private var defense:Int;
	private var attack:Int;
	private var speed:Int;
	private var cargo:Int;

	private var currentHp:Int;
	private var currentDefense:Int;
	private var currentAttack:Int;
	private var currentSpeed:Int;
	private var currentCargo:Int;

	// Could be a stat if we ever develop the battles further.
	// Right now it is just used in the battle simulator.
	//
	public var range:Int = 10;

	// Dummy component
	//
	static public var emptyComponent:Component = new Component();

	// Base stats here
	//
	public function new(hp:Int = 10, defense:Int = 2, attack:Int = 0, speed:Int = 0, cargo:Int = 0, nSpots:Int = 5)
	{
		this.nSpots = nSpots;
		components = [for (i in 0...nSpots) emptyComponent];

		// Set base stats
		//
		this.hp = hp;
		this.defense = defense;
		this.attack = attack;
		this.speed = speed;
		this.cargo = cargo;
		reset();
	}

    public function getComponent(spot:Int):Component {
        return components[spot];
    }

    public function hasShield():Bool {
    	for (component in this.components) {
    		if (component.getName() == "shield") {
    			return true;
    		}
    	}
    	return false;
    }

	public function addComponent(component:Component, spot:Int)
	{
		// Is this a valid spot?
		//
		Deb.assert(spot < nSpots);
		Deb.assert(emptySpot(spot));

		// Add the component, and apply modifiers
		//
		components[spot] = component;
		defense += component.getDefense();
		currentDefense += component.getDefense();
		attack += component.getAttack();
		currentAttack += component.getAttack();
		speed += component.getSpeed();
		currentSpeed += component.getSpeed();
		cargo += component.getCargo();
		currentCargo += component.getCargo();
	}

	public function removeComponent(spot:Int):Component
	{
		// Is this a valid spot?
		//
		Deb.assert(spot < nSpots);
		Deb.assert(!emptySpot(spot));

		// Undo the modifiers, and remove the component;
		//
		var component:Component = components[spot];
		defense -= component.getDefense();
		currentDefense -= component.getDefense();
		attack -= component.getAttack();
		currentAttack -= component.getAttack();
		speed -= component.getSpeed();
		currentSpeed -= component.getSpeed();
		cargo -= component.getCargo();
		currentCargo -= component.getCargo();

		components[spot] = emptyComponent;

		return component;
	}

	public function addSpot()
	{
		this.nSpots++;
		components.push(emptyComponent);
	}

	public function reset()
	{
		currentHp = hp;
		currentDefense = defense;
		currentAttack = attack;
		currentSpeed = speed;
		currentCargo = cargo;
	}

	public function emptySpot(spot:Int):Bool { return components[spot] == emptyComponent; }

	public function resetComponents()
	{
		for (spot in 0...nSpots)
		{
			removeComponent(spot);
		}
	}

	// Accessors
	//
	public function getHp() { return currentHp; }
	public function getDefense() { return currentDefense; }
	public function getAttack() { return currentAttack; }
	public function getSpeed() { return currentSpeed; }
	public function getCargo() { return currentCargo; }
	public function getSpots() { return nSpots; }

	// Current stuff modifiers
	//
	public function modHp(delta:Int) { currentHp += delta; }
	public function modDefense(delta:Int) { currentDefense += delta; }
	public function modAttack(delta:Int) { currentAttack += delta; }
	public function modSpeed(delta:Int) { currentSpeed += delta; }
}
