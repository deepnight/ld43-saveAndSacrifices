import h2d.Sprite;
import mt.heaps.HParticle;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.deepnight.Tweenie;
import mt.MLib;


class Fx extends mt.Process {
	public var pool : ParticlePool;

	public var bgAddSb    : h2d.SpriteBatch;
	public var bgNormalSb    : h2d.SpriteBatch;
	public var topAddSb       : h2d.SpriteBatch;
	public var topNormalSb    : h2d.SpriteBatch;

	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.gameElements.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_TOP);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(topAddSb, Const.DP_FX_TOP);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();

		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}

	public function clear() {
		pool.killAll();
	}

	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.gameElements.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c=0xFF00FF, ?short=false) {
		#if debug
		if( e==null )
			return;

		markerCase(e.cx, e.cy, c, short);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;

		var p = allocTopAdd(getTile("dot"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerFree(x:Float, y:Float, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("dot"), x,y);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.dr = 0.3;
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		var tf = new h2d.Text(Assets.font, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.frict = 0.92;
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_TOP);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});
	}

	function collidesGround(p:HParticle) {
		return
			!level.hasColl( Std.int(p.x/Const.GRID), Std.int((p.y-2)/Const.GRID) ) &&
			level.hasColl( Std.int(p.x/Const.GRID), Std.int((p.y+1)/Const.GRID) );
	}

	function collides(p:HParticle) {
		return level.hasColl( Std.int(p.x/Const.GRID), Std.int((p.y+1)/Const.GRID) );
	}

	function _groundPhysics(p:HParticle) {
		if( collides(p) ) {
			// p.gy = 0;
			p.dy = 0;
			p.dx = rnd(0,0.2,true);
		}
	}

	public function wallGlow(x:Float, y:Float, c:UInt, dir:Int) {
		for(i in 0...4) {
			var p = allocTopAdd(getTile("dot"), x+rnd(0,1,true),y-rnd(0,Const.GRID));
			p.colorize(c);
			p.scaleY = rnd(1,2);
			// p.gy = rnd(0,0.1);
			p.frict = 0.9;
			p.setFadeS(rnd(0.3,0.7), 0, rnd(0.2,0.3));
			p.lifeS = rnd(0.3,0.5);
			p.onUpdate = _groundPhysics;
		}
		for(i in 0...3) {
			var p = allocTopAdd(getTile("dot"), x+rnd(0,1,true),y-rnd(0,Const.GRID));
			p.colorize(c);
			p.scaleX = rnd(1,3);
			p.gx = rnd(0,0.06)*dir;
			p.frict = rnd(0.7,0.8);
			p.setFadeS(rnd(0.3,0.7), 0, rnd(0.2,0.3));
			p.lifeS = rnd(0.3,0.5);
		}
	}

	public function wallPenetrate(x:Float, y:Float, c:UInt, dir:Int) {
		for(i in 0...7) {
			var p = allocTopAdd(getTile("dot"), x+rnd(0,1,true),y-rnd(0,Const.GRID));
			p.colorize(c);
			p.scaleY = rnd(1,2);
			// p.gy = rnd(0,0.1);
			p.frict = 0.9;
			p.setFadeS(rnd(0.3,0.7), 0, rnd(0.2,0.3));
			p.lifeS = rnd(0.3,0.5);
			p.onUpdate = _groundPhysics;
		}
		for(i in 0...7) {
			var p = allocTopAdd(getTile("dot"), x+rnd(0,1,true),y-rnd(0,Const.GRID));
			p.colorize(c);
			p.gx = rnd(0.01,0.03)*dir;
			p.frict = rnd(0.7,0.8);
			p.setFadeS(rnd(0.3,0.7), 0, rnd(0.2,0.3));
			p.lifeS = rnd(0.3,0.5);
		}
		for(i in 0...4) {
			var p = allocTopAdd(getTile("dot"), x-dir,y-rnd(0,Const.GRID));
			p.colorize(c);
			p.scaleX = rnd(2,4);
			p.gx = rnd(0.01,0.03)*-dir;
			p.frict = rnd(0.7,0.8);
			p.setFadeS(rnd(0.3,0.7), 0, rnd(0.2,0.3));
			p.lifeS = rnd(0.3,0.5);
		}
	}

	override function update() {
		super.update();

		pool.update(game.dt);
	}
}