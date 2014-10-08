package;

class Component
{
	private var defense:Int;
	private var attack:Int;
	private var speed:Int;
	private var cargo:Int;
	private var cost:Int;

	public function new(defense:Int = 0, attack:Int = 0, speed:Int = 0, cargo:Int = 0, cost:Int = 0)
	{
		this.defense = defense;
		this.attack = attack;
		this.speed = speed;
		this.cargo = cargo;
		this.cost = cost;
	}

	public function getDefense() { return defense; }
	public function getAttack() { return attack; }
	public function getSpeed() { return speed; }
	public function getCargo() { return cargo; }
	public function getcost() { return cost; }
}