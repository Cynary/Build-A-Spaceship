package;

import Date;
import flixel.addons.ui.FlxUIList;

class Player
{
	private var money:Int;
	private var ship:Ship;
	private var carrying:Component = Ship.emptyComponent;

	public function new(initialMoney:Int, initialShip:Ship)
	{
		money = initialMoney;
		ship = initialShip;
	}

	public function addShip(ship:Ship)
	{
		this.ship = ship;
	}

	public function pickup(component:Component)
	{
		carrying = component;
	}

	public function drop()
	{
		carrying = Ship.emptyComponent;
	}

	public function getCarrying()
	{
		return carrying;
	}

	public function buyComponent(spot:Int):Bool
	{
		var component = carrying;
		carrying = Ship.emptyComponent;
		if (money < component.getCost() || !ship.emptySpot(spot))
		{
			return false;
		}
		money -= component.getCost();
		ship.addComponent(component, spot);
		return true;
	}

	public function getShip():Ship { return ship; }
	public function getMoney():Int { return money; }

	public function sellComponent(spot:Int)
	{
		if (!ship.emptySpot(spot))
		{
			var component = ship.removeComponent(spot);
			money += component.getCost();
		}
	}

	public function goMission():CaptainLog
	{
		var cptLog = new CaptainLog(Date.now());
		if (ship.getSpeed() <= 0)
		{
			cptLog.add(0,"Your ship did not have the power to get off the ground.");
		}
		else
		{
			var banditShip1 = new Ship(5,0,0,1);
			var banditShip2 = new Ship(10,0,0,1);
			var banditShip3 = new Ship(10,4,2,3);
			var mission:Array<Events.BanditsEvent> = [
				new Events.BanditsEvent(cptLog,banditShip1),
				new Events.BanditsEvent(cptLog,banditShip2),
				new Events.BanditsEvent(cptLog,banditShip3),
			];
			for (event in mission)
			{
				event.applyEvent(ship);
			}
			money += cptLog.getMoney();

			ship.reset();
			if (cptLog.isDestroyed())
			{
				ship.resetComponents();
			}
		}
		return cptLog;
	}
}