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
		viewport = new Viewport();

		renderBg();
		startLevel(Tutorial);
		new GameCinematic("intro");
	}

	public function restartLevel() {
		startLevel(level.lid);
	}

	public function startLevel(lid:Data.RoomKind) {
		if( level!=null ) {
			level.destroy();
			for(e in Entity.ALL)
				e.destroy();
			gc();
			fx.clear();
		}

		level = new Level(lid);
		viewport.track(hero, true);
	}

	public function nextLevel() {
		if( level.infos.index+1>=Data.room.all.length ) {
			new GameCinematic("credits");
		}
		else {
			startLevel(Data.room.all[level.infos.index+1].id);
		}

	}

	function renderBg() {
		bg.clear();
		var t = Assets.gameElements.getTile("gradient");
		var nx = MLib.ceil( w()/Const.SCALE / t.width );
		var ny = MLib.ceil( h()/Const.SCALE / t.height );
		for(x in 0...nx)
		for(y in 0...ny)
			bg.add(x*t.width, y*t.height, t);
	}

	override function onResize() {
		super.onResize();
		renderBg();
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

		fx.destroy();
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
			restartLevel();

		#if debug
		// Next level
		if( ca.startPressed() )
			nextLevel();
		if( ca.isKeyboardPressed(Key.NUMPAD_MULT) )
			if( cd.has("scrollLock") )
				cd.unset("scrollLock");
			else
				cd.setS("scrollLock",Const.INFINITE);
		#end

		if( !GameCinematic.hasAny() && en.Peon.ALL.length==0 && !cd.has("gameEndLock") ) {
			if( en.Exit.getSavedCount()==0 )
				new GameCinematic("lost");
			else
				new GameCinematic("levelComplete");
		}
	}
}

