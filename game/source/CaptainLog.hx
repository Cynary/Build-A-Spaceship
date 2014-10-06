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

	public function new(startDate:Date)
	{
		start = Date.fromTime(startDate.getTime());
		dates = new Array<Date>();
		texts = new Array<String>();
	}

	public function add(duration:Float, text:String)
	{
		dates.push(start);
		texts.push(text);
		start = DateTools.delta(start, duration);
	}

	public function createSprite(width:Int, height:Int, x:Int = 0, y:Int = 0):FlxUIList
	{
		var entries:Array<IFlxUIWidget> = [for (i in 0...dates.length) new FlxUIText(0,0,width,'Date: ${dates[i].toString()}\n\n${texts[i]}')];
		return new FlxUIList(x,y,entries,width,height);
	}
}