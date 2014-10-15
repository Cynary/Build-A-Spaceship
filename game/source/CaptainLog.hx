package;

import Date;
import DateTools;

import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;

class CaptainLog
{
	private var dates:Array<Date>;
	private var texts:Array<String>;
	private var start:Date;
	private var moneyEarned:Int;
	private var destroyed:Bool;

	public function new(startDate:Date)
	{
		start = Date.fromTime(startDate.getTime());
		dates = new Array<Date>();
		texts = new Array<String>();
		moneyEarned = 0;
		destroyed = false;
	}

	public function add(duration:Float, text:String, ship:Ship, ?forceWrite:Bool )
	{
		if (!destroyed || forceWrite)
		{
			dates.push(Date.fromTime(start.getTime()));
			texts.push('$text\n\nShip status: HP ${ship.getHp()}, Def ${ship.getDefense()}, Attack ${ship.getAttack()}, Speed ${ship.getSpeed()}, Cargo ${ship.getCargo()}');
			start = DateTools.delta(start, duration);
		}
	}

	public function createSprite(width:Int, height:Int, x:Int = 0, y:Int = 0):FlxUIList
	{
		var entries:Array<IFlxUIWidget> = [for (i in 0...dates.length) new FlxUIText(0,0,width,'Date: ${dates[i].toString()}\n\n${texts[i]}\n\n')];
		return new FlxUIList(x,y,entries,width,height);
	}

	public function earnMoney(money:Int)
	{
		if (!destroyed)
		{
			moneyEarned += money;
		}
	}

	public function getMoney()
	{
		return moneyEarned;
	}

	public function destroy()
	{
		destroyed = true;
	}

	public function isDestroyed()
	{
		return destroyed;
	}
}