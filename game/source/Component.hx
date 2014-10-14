package;

class Component
{
	private var defense:Int;
	private var attack:Int;
	private var speed:Int;
	private var cargo:Int;
	private var cost:Int;
	private var name:String;
	private var shortDisplay:String;

	public function new(defense:Int = 0, attack:Int = 0, speed:Int = 0, cargo:Int = 0, cost:Int = 0, name:String = "", shortDisplay:String = "")
	{
		this.defense = defense;
		this.attack = attack;
		this.speed = speed;
		this.cargo = cargo;
		this.cost = cost;
		this.name = name;
		this.shortDisplay = shortDisplay;
	}

	public function getDefense() { return defense; }
	public function getAttack() { return attack; }
	public function getSpeed() { return speed; }
	public function getCargo() { return cargo; }
	public function getCost() { return cost; }
	public function getName() { return name; }

	private function statSummary(v:Int, code:String) : String {
		if (v == 0) {
			return "";
		}
		var s:String = "";
		if (v > 0) {
			s = "+";
		}
		s += v + code + " ";
		return s;
	}

	public function summary():String {
		var s:String = '$$${this.cost} ';
		if (shortDisplay != "") {
			s += '${this.shortDisplay} ';
		}
		s += statSummary(defense, "D");
		s += statSummary(attack, "A");
		s += statSummary(speed, "S");
		s += statSummary(cargo, "C");
		return s;
	}
}