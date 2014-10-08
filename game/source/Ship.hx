package;

class Ship
{
	// Layout
	//
	private var nSpots:Int;
	private var components:Array<Components>;

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

	// Dummy component
	//
	static private var EmptyComponent:Component = new Component();

	// Base stats here
	//
	public function new(hp:Int = 10, defense:Int = 2, attack:Int = 0, speed:Int = 0, cargo:Int = 0, nSpots:Int = 3)
	{
		this.nSpots = nSpots;
		components = [for (i in 1...nSpots) EmptyComponent];

		// Set base stats
		//
		this.hp = currentHp = hp;
		this.defense = currentDefense = defense;
		this.attack = currentAttack = attack;
		this.speed = currentSpeed = speed;
		this.cargo = currentCargo = cargo;
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

	public function removeComponent(spot:Int)
	{
		// Is this a valid spot?
		//
		Deb.assert(spot < nSpots);
		Deb.assert(!emptySpot(spot));

		// Undo the modifiers, and remove the component;
		//
		var component = components[spot];
		defense -= component.getDefense();
		currentDefense -= component.getDefense();
		attack -= component.getAttack();
		currentAttack -= component.getAttack();
		speed -= component.getSpeed();
		currentSpeed -= component.getSpeed();
		cargo -= component.getCargo();
		currentCargo -= component.getCargo();

		components[spot] = EmptyComponent;
	}

	public function addSpot()
	{
		this.nSpots++;
		components.push(EmptyComponent);
	}

	public function reset()
	{
		currentHp = hp;
		currentDefense = defense;
		currentAttack = attack;
		currentSpeed = speed;
		currentCargo = cargo;
	}

	public function emptySpot(spot:Int):Bool { return components[spot] == EmptyComponent}

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
	public function getSpeed() { return speed; }
	public function getCargo() { return cargo; }
	public function getSpots() { return nSpots; }
}
