package;

import Date;

class Player
{
	private var money:Int;
	private var ship:Ship;

	public function new(initialMoney:Int, initialShip:Ship)
	{
		money = initialMoney;
		ship = initialShip;
	}

	public function addShip(ship:Ship)
	{
		this.ship = ship;
	}

	public function buyComponent(component:Component, spot:Int):Bool
	{
		if (money < component.getCost())
		{
			return false;
		}
		money -= component.getCost();
		ship.addComponent(component, spot);
		return true;
	}

	public function getShip():Ship { return ship; }

	public function sellComponent(spot:Int)
	{
		var component = ship.removeComponent(spot);
		money += component.getCost();
	}

	public function goMission():FlxUIList
	{
		cptLog = new CaptainLog(Date.now());
		cptLog.add(10*60*10000, "dummy entry");
		return cptLog.createSprite(640, 480);
	}
}