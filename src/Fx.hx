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

		markerCase(e.cx, e.cy, short?0.03:3, c);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?sec=3.0, ?c=0xFF00FF) {
		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.frict = 0.92;
		p.lifeS = sec;

		var p = allocTopAdd(getTile("dot"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.frict = 0.92;
		p.lifeS = sec;
	}

	public function markerFree(x:Float, y:Float, ?sec=3.0, ?c=0xFF00FF) {
		var p = allocTopAdd(getTile("dot"), x,y);
		p.setCenterRatio(0.5,0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		// p.dr = 0.3;
		p.frict = 0.92;
		p.lifeS = sec;
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
			p.gy = 0;
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

	public function darkness(x:Float, y:Float, c:UInt) {
		var p = allocTopNormal(getTile("smoke"), x+rnd(0,4,true), y+rnd(0,4,true));
		p.colorize(c);
		p.setScale(rnd(2.5,3)*Const.GRID/p.t.width);
		p.rotation = rnd(0,6.28);
		p.setFadeS(rnd(0.6,0.9), rnd(0.3,0.4), rnd(0.5,1.2));
		p.dr = rnd(0,0.002,true);
		p.lifeS = rnd(0.3,0.7);
		p.delayS = rnd(0,0.3);
	}

	public function targetLine(from:Entity, to:Entity, c:UInt) {
		var p = allocTopAdd(getTile("targetLine"), from.centerX, from.centerY);
		p.colorize(c);
		p.setCenterRatio(0,0.5);
		p.scaleX = from.distPx(to) / p.t.width;
		p.scaleY = 2;
		p.rotation = Math.atan2(to.centerY-from.centerY, to.centerX-from.centerX);
		// p.moveAng(p.rotation, 1);
		// p.frict = 0.92;
		p.setFadeS(0.3, 0.1, 0.3);
		p.lifeS = 0.2;
	}

	public function lightStatusChange(l:en.Light, e:Entity, c:UInt) {
		var a = Math.atan2(e.centerY-l.centerY, e.centerX-l.centerX);
		var d = l.radius;
		for(i in 0...20) {
			var a = a+rnd(0,0.1,true);
			var p = allocTopAdd(getTile("line"), l.centerX+Math.cos(a)*d, l.centerY+Math.sin(a)*d);
			p.colorize(c);
			p.setFadeS(rnd(0.3,0.5), 0, rnd(0.2,0.4));
			p.scaleX = rnd(0.6,0.8,true);
			p.scaleY = rnd(1,2,true);
			p.rotation = a+1.57;
			// p.moveAng(a, rnd(3,6));
			// p.frict = rnd(0.7,0.8);
			p.lifeS = rnd(0.1,0.3);
		}

		for(i in 0...15) {
			var p = allocTopAdd(getTile("dot"), e.centerX+rnd(0,10,true), e.centerY+rnd(0,10,true));
			p.alphaFlicker = 0.4;
			p.colorize(c);
			p.setFadeS(rnd(0.4,0.8), rnd(0.1,0.3), rnd(0.5,1.2));
			p.moveAwayFrom(e.centerX, e.centerY, rnd(1,2));
			p.frict = rnd(0.9,0.92);
			p.delayS = rnd(0,0.1);
			p.lifeS = rnd(0.2,0.9);
		}
	}

	public function lightRepel(l:en.Light, e:Entity, c:UInt) {
		var a = Math.atan2(e.centerY-l.centerY, e.centerX-l.centerX);
		var d = l.distPx(e);
		for(i in 0...30) {
			var a = a+rnd(0,0.2,true);
			var d = d-rnd(6,10);
			var p = allocTopAdd(getTile("line"), l.centerX+Math.cos(a)*d, l.centerY+Math.sin(a)*d);
			p.colorize(c);
			p.setFadeS(rnd(0.5,0.8), 0, rnd(0.2,0.4));
			p.scaleX = rnd(0.7,1.2,true);
			p.rotation = a+1.57;
			p.moveAng(a, rnd(3,6));
			p.frict = rnd(0.7,0.8);
			p.lifeS = rnd(0.1,0.3);
		}
	}

	public function candleSmoke(x:Float, y:Float) {
		for(i in 0...2) {
			var p = allocBgNormal(getTile("dot"), x, y-rnd(0,2));
			p.setFadeS(rnd(0.1,0.2), rnd(0.1,0.2), rnd(0.2,0.4));
			p.gx = rnd(0,0.01);
			p.gy = -rnd(0.03,0.05);
			p.frict = rnd(0.7,0.8);
			p.lifeS = rnd(0.2,0.4);
		}
	}

	public function explosion(x:Float,y:Float, r:Float) {
		// Core
		var p = allocTopAdd(getTile("explosion"), x,y);
		p.playAnimAndKill(Assets.gameElements, "explosion",0.33);
		p.setScale(r*2/p.t.width);
		p.rotation = rnd(0,6.28);

		// Side explosions
		var n = 10;
		for(i in 0...n) {
			var a = i/n*6.28 + rnd(0,0.3,true);
			var d = r*rnd(0.2,0.8);
			var p = allocTopAdd(getTile("explosion"), x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.playAnimAndKill(Assets.gameElements, "explosion",rnd(0.33,0.5));
			p.setScale(r*2/p.t.width * rnd(0.3,0.5));
			p.rotation = rnd(0,6.28);
			p.delayS = rnd(0, 0.1) + i/n*0.2;
		}

		// Lines
		var n = 40;
		for(i in 0...n) {
			var a = i/n*6.28 + rnd(0,0.3,true);
			var d = r*rnd(0.7,1);
			var p = allocTopAdd(getTile("line"), x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.colorize(0xff5100);
			p.alpha = rnd(0.3,0.5);
			p.rotation = a;
			p.scaleX = rnd(1,3);
			p.moveAng(a, rnd(8,10));
			p.frict = rnd(0.8,0.9);
			p.scaleXMul = rnd(0.95,0.96);
			p.lifeS = rnd(0.3,0.5);
		}

		// Smoke
		var n = 10;
		for(i in 0...n) {
			var p = allocBgNormal(getTile("smoke"), x+rnd(0,20,true), y+rnd(0,20,true));
			p.setFadeS(rnd(0.2,0.3), 0, rnd(1,2));
			p.colorize(0x0);
			p.rotation = rnd(0,6.28);
			p.gy = -rnd(0.05,0.06);
			p.setScale(rnd(0.6,0.9,true));
			p.frict = rnd(0.8,0.9);
			p.dr = rnd(0,0.001,true);
			p.lifeS = rnd(0.5,1);
		}
	}

	function _bloodPhysics(p:HParticle) {
		if( collides(p) ) {
			p.dy = p.gy = 0;
			p.dx *= 0.5;
			p.frict = rnd(0.7,0.8);
			if( collidesGround(p) ) {
				p.rotation = 0;
				p.scaleX = rnd(2,3);
				p.scaleY = rnd(0.4,0.7);
			}
			p.onUpdate = null;
		}
	}

	public function showCoord(cx:Int, cy:Int, ?sec=6.0, ?c=0x2fb2e3) {
		var freq = 0.4;
		var n = MLib.ceil(sec/freq);
		for(i in 0...n) {
			var p = allocTopAdd(getTile("square"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
			p.colorize(c);
			p.setScale(2);
			p.ds = -0.07;
			p.dsFrict = 0.9;
			p.lifeS = freq*0.5;
			p.delayS = freq*i;
		}
	}

	public function fakeExitingPeon(e:en.Peon) {
		var p = allocBgNormal(getTile("peonRun"), (e.cx+0.2)*Const.GRID, (e.cy+1)*Const.GRID);
		p.setCenterRatio(0.5,1);
		p.setFadeS(1,0,0.5);
		p.playAnimLoop(Assets.gameElements, "peonRun");
		p.dx = 0.19;
		p.dy = -0.19;
		p.lifeS = 0.2;
	}

	public function gibs(x:Float, y:Float) {
		for(i in 0...20) {
			var p = allocBgNormal(getTile("gib"), x+rnd(0,10,true), y+rnd(0,5,true));
			p.colorize(mt.deepnight.Color.interpolateInt(0x6f0d0d, 0xaf3030, rnd(0,1)));
			p.setFadeS(rnd(0.7,1),0,rnd(3,5));
			p.dx = rnd(0,1,true);
			p.dy = -rnd(2,5);
			p.gy = rnd(0.1,0.2);
			p.rotation = rnd(0,6.28);
			p.frict = 0.94;
			p.lifeS = rnd(8,12);
			p.onUpdate = _bloodPhysics;
		}
	}

	function _feather(p:HParticle) {
		p.rotation = Math.cos(ftime*p.data0 + p.data1)*0.2;
	}
	public function feather(x:Float, y:Float) {
		var p = allocBgNormal(getTile("feather"),x,y);
		p.setCenterRatio(0.5, -rnd(5,8));
		p.setFadeS(rnd(0.5,1), 0.1, rnd(1,2));
		p.scaleX = rnd(0.4,1,true);
		p.scaleY = rnd(0.4,1,true);
		p.scaleYMul = rnd(0.98,0.99);
		p.moveAng(rnd(0,6.28), rnd(1,4));
		p.gx = rnd(0,0.02);
		p.gy = rnd(0.05,0.10);
		p.frict = rnd(0.8,0.9);
		p.lifeS = rnd(1,2);

		p.data0 = rnd(0.10,0.25);
		p.data1 = rnd(0,6.28);
		p.onUpdate = _feather;
	}

	public function lightZone(x:Float, y:Float, r:Float, c:UInt) {
		var n = irnd(20,30);
		for(i in 0...n) {
			var a = 6.28*i/n;
			var p = allocTopAdd(getTile("line"), x+Math.cos(a)*r, y+Math.sin(a)*r);
			p.colorize(c);
			p.setFadeS(rnd(0.1,0.2), 0, rnd(0.2,0.4));
			p.scaleX = rnd(0.7,1.2,true);
			p.rotation = a+1.57;
			p.moveAng(a, rnd(0,0.2,true));
			p.frict = rnd(0.92,0.93);
			p.lifeS = rnd(0.1,0.3);
		}
		// Core
		for(i in 0...5) {
			var p = allocTopAdd(getTile("line"), x,y);
			p.colorize(c);
			p.setFadeS(rnd(0.1,0.25), rnd(0.1,0.2), rnd(0.2,0.3));
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.01,true);
			p.scaleX = i==0 ? rnd(1,2) : rnd(0.8,1);
			p.scaleY = rnd(1,2);
			p.scaleXMul = rnd(0.98,1.01);
			p.lifeS = rnd(0.2,0.3);
		}
	}

	override function update() {
		super.update();

		pool.update(game.dt);
	}
}