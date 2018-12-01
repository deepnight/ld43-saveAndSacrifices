import mt.Process;
import mt.MLib;
import mt.deepnight.CdbHelper;

class Game extends mt.Process {
	public static var ME : Game;

	public var ca : mt.heaps.Controller.ControllerAccess;
	public var hero : en.Hero;
	public var level : Level;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		createRootInLayers(Main.ME.root, Const.DP_BG);

		new en.Hero();
	}

	public function onCdbReload() {
	}

	function gc() {
		if( Entity.GC==null )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	override function update() {
		super.update();

		// Updates
		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate(dt);
		for(e in Entity.ALL) if( !e.destroyed ) e.update();
		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();

	}
}

