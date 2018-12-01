import mt.Process;
import mt.MLib;
import mt.deepnight.CdbHelper;
import hxd.Key;

class Game extends mt.Process {
	public static var ME : Game;

	public var ca : mt.heaps.Controller.ControllerAccess;
	public var hero1 : en.h.Ghost;
	public var hero2 : en.Hero;
	public var hero3 : en.Hero;
	public var level : Level;
	public var fx : Fx;
	public var scroller : h2d.Layers;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_MAIN);

		fx = new Fx();
		level = new Level(Test);
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

	override function onDispose() {
		super.onDispose();

		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	override function update() {
		super.update();

		// Updates
		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate(dt);
		for(e in Entity.ALL) if( !e.destroyed ) e.update();
		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();


		// Global controls
		if( ca.xPressed() ) {
			if( hero1.active )
				hero2.activate();
			else if( hero2.active )
				hero3.activate();
			else
				hero1.activate();
		}
		if( ca.selectPressed() )
			Main.ME.startGame();
	}
}

