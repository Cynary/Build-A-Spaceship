package;

class Component
{
	private var defense:Int;
	private var attack:Int;
	private var speed:Int;
	private var cargo:Int;
	private var cost:Int;
	private var name:String;

	public function new(defense:Int = 0, attack:Int = 0, speed:Int = 0, cargo:Int = 0, cost:Int = 0, name:String = "")
	{
		this.defense = defense;
		this.attack = attack;
		this.speed = speed;
		this.cargo = cargo;
		this.cost = cost;
		this.name = name;
	}

	public function getDefense() { return defense; }
	public function getAttack() { return attack; }
	public function getSpeed() { return speed; }
	public function getCargo() { return cargo; }
	public function getCost() { return cost; }
	public function getName() { return name; }
}