package;

import Date;
import flixel.addons.ui.FlxUIList;

class Player
{
	private inline static var REPAIR_COST:Int = 3;
	private inline static var CARGO_VALUE:Int = 3;
	private var money:Int;
	private var ship:Ship;
	private var carrying:Component = Ship.emptyComponent;
	private var missionNumber:Int;

	public function new(initialMoney:Int, initialShip:Ship)
	{
		money = initialMoney;
		ship = initialShip;
		missionNumber = 0;
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
			var mission:Array<Events.Event> = [
				new Events.SolarWindEvent(cptLog, /* +speed */ 2, /* -hp */ 6),
				new Events.BanditsEvent(cptLog,banditShip2),
				new Events.AsteriodEvent(cptLog, /* speed > */ 2, /* -hp */ 7),
				new Events.BanditsEvent(cptLog,banditShip1),
				new Events.BlackHoleEvent(cptLog, /* speed > */ 4, /* +speed */ 1, /* -hp */ 10),
			];
			var mission2:Array<Events.Event> = [
				new Events.AsteriodEvent(cptLog, /* speed > */ 4, /* -hp */ 7),
				new Events.BlackHoleEvent(cptLog, /* speed > */ 6, /* +speed */ 1, /* -hp */ 10),
				new Events.RaceEvent( cptLog , 8 , 5 , 5)
			];
			var mission3:Array<Events.Event> = [
				new Events.SolarWindEvent(cptLog, /* +speed */ 2, /* -hp */ 2),
				new Events.AsteriodEvent(cptLog, /* speed > */ 9, /* -hp */ 7),
				new Events.BanditsEvent(cptLog,banditShip3),
				new Events.BlackHoleEvent(cptLog, /* speed > */ 11, /* +speed */ 1, /* -hp */ 10)
			];
			var missions:Array< Array<Events.Event> > = [
				mission,
				mission2,
				mission3
			];
			var currentMission:Array<Events.Event> =  missions[missionNumber % missions.length];
			for (event in currentMission)
			{
				event.applyEvent(ship);
				if (ship.getHp() <= 0) {
					cptLog.add(0.0, "Your ship has no health left and disintegrates into space debris.");
					cptLog.destroy();
					break;
				}
				if (ship.getSpeed() < 0) {
					cptLog.add(0.0, "Looks like your ship's engines gave out. The ship drifts until the nearest star, then stops drifting.");
					cptLog.destroy();
					break;
				}
			}
			money += cptLog.getMoney();

			ship.reset();
			if (cptLog.isDestroyed())
			{
				ship.resetComponents();
				cptLog.add(2*60, "You must pay $" + REPAIR_COST + " to get your ship fixed", true );
				money -= REPAIR_COST;
			}
			else
			{
				missionNumber++;
				cptLog.add(2*60, "You finished your mission and move on to the next.");

				money += CARGO_VALUE*ship.getCargo();
				if (ship.getCargo() > 0)
				{
					cptLog.add(2*60, "You earn $" + CARGO_VALUE*ship.getCargo() + " for delivering " + ship.getCargo() + " units of cargo.");
				}
			}
		}
		return cptLog;
	}
}