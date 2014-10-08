package;

import Math;

class Event
{
	private var optional:Bool = false;
	private var cptLog:CaptainLog;

	private var text_win:String = "You Win!";
	private var text_lose:String = "You Lose!";
	private var text_randWin:String =  "An angel came from heaven, and made you win.";
	private var text_randLose:String ="A meteorite made you lose.";

	private var p_randWin:Float = 0.0;
	private var p_randLose:Float = 0.0;

	public function new(log:CaptainLog) { cptLog = log; }
	public function applyEvent(ship:Ship):Void {}
	public function isOptional():Bool { return optional; }
}

enum Reason {
	ESCAPE;
	DESTROY;
	TIE;
	OVER_POWER;
	BOTH_DIE;
}

private class BattleResults
{
	public var reason:EnumValue;
	public var winner:Ship;
	public var loser:Ship;
	public var turns:Int;
	public var hpDelta:Int;
	public static var turnDuration:Int = 30*60*1000;

	public function new(reason:EnumValue, winner:Ship, loser:Ship, turns:Int, hpDelta:Int = 0)
	{
		this.reason = reason;
		this.winner = winner;
		this.loser = loser;
		this.turns = turns;
		this.hpDelta = hpDelta;
	}
}

class BattleSimulator
{
	public static function max(a:Int, b:Int)
	{
		return (a>b)?a:b;
	}
	// Simulates an encounter with bandits.
	// Adds the possibility of escape
	// Captain's strategy: fire at them until they either explode, or we escape.
	// If the ships are evenly matched, they hail each other, and leave.
	//
	public static function simulateBandits(captainShip:Ship, banditShip:Ship):BattleResults
	{
		var turnDamageFromBandit:Int = max(banditShip.getAttack()-captainShip.getDefense(),0);
		var turnDamageFromCaptain:Int = max(captainShip.getAttack()-banditShip.getDefense(),0);

		var res:BattleResults;

		if (turnDamageFromBandit == 0)
		{
			// If the bandit doesn't hurt us at all, then we can either:
			if (turnDamageFromCaptain == 0)
			{
				// Tie
				// We watch as our attacks bounce off each other's shields. Our ships are equally matched. I tip my hat to the opposing captain, and we part ways.
				res = new BattleResults(TIE, captainShip, banditShip, 1);
			}
			else
			{
				// Over power him
				// They feel the impact of our weapons, and watch terrified as their attacks bounce off our shields without causing a scratch. They run away in terror.
				res = new BattleResults(OVER_POWER, captainShip, banditShip, 1);
			}
		}
		else
		{
			// How long until each ship dies?
			//
			var turnsToKillCaptain:Int = Math.ceil(captainShip.getHp()*1./turnDamageFromBandit);
			var turnsToKillBandit:Int = (turnDamageFromCaptain == 0) ? turnsToKillCaptain+1 : Math.ceil(banditShip.getHp()*1./turnDamageFromCaptain);
			// How long until we escape?
			//
			var turnsToEscape:Int = (captainShip.getSpeed() == banditShip.getSpeed()) ? turnsToKillCaptain+1 : Math.ceil(banditShip.range/(captainShip.getSpeed()-banditShip.getSpeed()));

			if (turnsToEscape < turnsToKillCaptain && turnsToEscape < turnsToKillBandit)
			{
				// Do we escape?
				//
				res = new BattleResults(ESCAPE, captainShip, banditShip, turnsToEscape, -turnsToEscape*turnDamageFromBandit);
			}
			else if (turnsToKillCaptain > turnsToKillBandit)
			{
				// Do we destroy the bandit?
				//
				res = new BattleResults(DESTROY, captainShip, banditShip, turnsToKillBandit, -turnsToKillBandit*turnDamageFromBandit);
			}
			else if (turnsToKillCaptain < turnsToKillBandit)
			{
				// Do we get destroyed?
				//
				res = new BattleResults(DESTROY, banditShip, captainShip, turnsToKillCaptain, -captainShip.getHp());
			}
			else
			{
				// Do both die at the same time?
				//
				Deb.assert(turnsToKillCaptain == turnsToKillBandit);
				res = new BattleResults(BOTH_DIE, banditShip, captainShip, turnsToKillCaptain, -captainShip.getHp());
			}
		}
		return res;
	}
}

// Introduce events here
//
class BanditsEvent extends Event
{
	// Bandits event class:
	//   Bandits are a ship
	//   Use the battle simulator to see what happens when we battle the bandits
	//   Two possible win conditions: we either escape, or we destroy them.
	//   Random victory/loss is possible.
	//

	private var banditShip:Ship;
	private var p_randVictory:Float;
	private var p_randLoss:Float;

	private var text_overPower:String = "over powered, you stole the bandit's money";
	private var text_escape:String = "escaped from bandits";
	private var text_tie:String = "tied with bandits";
	private var text_mutualDestruction:String = "ship and bandit destroyed";
	private var text_destroy:String = "bandit destroyed, you stole its money.";
	private var text_destroyed:String = "ship destroyed by bandits";

	private var text_randVictory:String = "randomly won";
	private var text_randLoss:String = "randomly lost";
	private var duration_randVictory:Int = 1*BattleResults.turnDuration;
	private var duration_randLoss:Int = 1*BattleResults.turnDuration;

	public function new(log, banditShip:Ship, p_randVictory:Float = 0.0, p_randLoss:Float = 0.0)
	{
		super(log);
		optional = false;

		this.banditShip = banditShip;

		Deb.assert(-0.0001 <= p_randVictory && 1.0001 >= p_randVictory);
		Deb.assert(-0.0001 <= p_randLoss && 1.0001 >= p_randLoss);
		this.p_randVictory = p_randVictory;
		this.p_randLoss = p_randLoss;
	}

	public override function applyEvent(captainShip:Ship)
	{
		if (cptLog.isDestroyed())
		{
			return;
		}

		var duration:Int;
		var text:String = "";
		var choice:Float = Math.random();
		if (choice <= p_randVictory)
		{
			text = text_randVictory;
			duration = duration_randVictory;
		}
		else if (choice <= p_randVictory+p_randLoss)
		{
			text = text_randLoss;
			duration = duration_randLoss;
		}
		else
		{
			var battleResults:BattleResults = BattleSimulator.simulateBandits(captainShip, banditShip);
			duration = battleResults.turns*BattleResults.turnDuration;
			switch (battleResults.reason)
			{
				case ESCAPE:
					text = text_escape;
				case OVER_POWER:
					cptLog.earnMoney(10);
					text = text_overPower;
				case TIE:
					text = text_tie;
				case BOTH_DIE:
					text = text_mutualDestruction;
				case DESTROY:
					if (battleResults.winner == captainShip)
					{
						cptLog.earnMoney(10);
						text = text_destroy;
					}
					else
					{
						cptLog.destroy();
						text = text_destroyed;
					}
			}
			captainShip.modHp(battleResults.hpDelta);
		}
		cptLog.add(duration, text);
	}
}