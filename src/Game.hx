import mt.Process;
import mt.MLib;
import mt.deepnight.CdbHelper;
import hxd.Key;

class Game extends mt.Process {
	public static var ME : Game;

	public var ca : mt.heaps.Controller.ControllerAccess;
	public var hero : en.h.Ghost;
	public var level : Level;
	public var fx : Fx;
	public var scroller : h2d.Layers;
	public var viewport : Viewport;
	var bg : h2d.TileGroup;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_MAIN);

		bg = new h2d.TileGroup(Assets.gameElements.tile);
		// bg = Assets.gameElements.h_get("gradient");
		root.add(bg, Const.DP_BG);

		fx = new Fx();
		level = new Level(Test);

		viewport = new Viewport();
		viewport.track(hero, true);
	}

	override function onResize() {
		super.onResize();
		bg.clear();
		var t = Assets.gameElements.getTile("gradient");
		var nx = MLib.ceil( w()/Const.SCALE / t.width );
		var ny = MLib.ceil( h()/Const.SCALE / t.height );
		for(x in 0...nx)
		for(y in 0...ny)
			bg.add(x*t.width, y*t.height, t);
		// bg.scaleX = (w()/Const.SCALE) / bg.tile.width;
		// bg.scaleY = (h()/Const.SCALE) / bg.tile.height;
	}

	public function onCdbReload() {
		onResize();
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


		// Change active hero
		// if( ca.xPressed() ) {
		// 	if( hero1.active )
		// 		hero2.activate();
		// 	else if( hero2.active )
		// 		hero3.activate();
		// 	else
		// 		hero1.activate();
		// }

		// Restart
		if( ca.selectPressed() )
			Main.ME.startGame();
	}
}

