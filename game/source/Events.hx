package;

class Event
{
	private var optional:Bool;
	private var cptLog:CaptainLog;

	public function new(log:CaptainLog) { cptLog = log; }
	private function test(ship:Ship):Bool { return true; }
	public function applyEvent(ship:Ship):Void {}
	public function isOptional():Bool { return optional; }
}

// Introduce events here
class BanditsEvent
{
}