package;

using haxe.macro.Tools;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;

class Deb
{
	static inline private var debug = false;

	macro public static function assert(e:Expr)
	{
		var res:Expr;
		if (debug)
		{
			return macro if (!$e) throw '${e.pos} assert(${e.toString()}) failed';
		}
		else
		{
			return macro if (!$e) trace('${e.pos} assert(${e.toString()}) failed');
		}
	}

	// Used for printing in assert statements
	//
	public static function p(i)
	{
		return true;
	}

	public static function trace(s:String) {
		if (debug) {
			trace(s);
		}
	}
}