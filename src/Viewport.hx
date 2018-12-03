import mt.deepnight.Lib;
import mt.MLib;

class Viewport extends mt.Process {
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public var x = 0.;
	public var y = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var wid(get,never) : Int;
	public var hei(get,never) : Int;
	public var screenWid(get,never) : Int;
	public var screenHei(get,never) : Int;
	var offY = -10;
	public var debugOffX = 0.;
	public var debugOffY = 0.;
	var target : Entity;

	public function new() {
		super(Game.ME);
	}

	inline function get_screenWid() return Boot.ME.s2d.width;
	inline function get_screenHei() return Boot.ME.s2d.height;

	inline function get_wid() {
		return MLib.ceil( Boot.ME.s2d.width / Const.SCALE );
	}

	inline function get_hei() {
		return MLib.ceil( Boot.ME.s2d.height / Const.SCALE );
	}


	public function track(e:Entity, ?immediate=false) {
		target = e;
		if( immediate ) {
			x = target.centerX;
			y = target.centerY+offY;
		}
	}

	var shakePow = 1.0;
	public function shakeS(t:Float, ?power=1.0) {
		cd.setS("shaking", t);
		shakePow = power;
	}

	override public function update() {
		super.update();

		// Balance between hero & mobs
		var tx = target.centerX + debugOffX;
		var ty = target.centerY + offY + debugOffY;

		var a = Math.atan2(ty-y, tx-x);
		var d = mt.deepnight.Lib.distance(x, y, tx, ty);
		var deadZoneX = 60;
		var deadZoneY = 30;
		if( MLib.fabs(x-tx)>=deadZoneX || MLib.fabs(y-ty)>=deadZoneY ) {
			var s = 0.5 * MLib.fclamp((d-deadZoneY)/200,0,1);
			// var s = 0.5 * MLib.fclamp((d-deadZone)/200,0,1);
			dx+=Math.cos(a)*s*dt;
			dy+=Math.sin(a)*s*dt;
		}

		//game.fx.markerFree(tx,ty,0xFFFF00, true);
		//game.fx.markerFree(x,y,0xFF00FF, true);

		if( !game.cd.has("scrollLock") ) {
			x+=dx*dt;
			y+=dy*dt;
			dx*=Math.pow(0.96,dt);
			dy*=Math.pow(0.96,dt);
		}
		// if( Lib.distance(x,y,tx,ty)<=35 ) {
		// 	dx*=0.7;
		// 	dy*=0.7;
		// }
		//x = MLib.fclamp(x,-screenWid,0);
		var prioCenter = 0;
		game.scroller.x = Std.int( -(x+prioCenter*level.wid*0.5*Const.GRID)/(1+prioCenter) + wid*0.5 );
		game.scroller.y = Std.int( -(y+prioCenter*level.hei*0.5*Const.GRID)/(1+prioCenter) + hei*0.5 );

		if( cd.has("shaking") ) {
			game.scroller.x += Math.cos(ftime*3.1)*1 * cd.getRatio("shaking") * shakePow;
			game.scroller.y += Math.sin(ftime*3.7)*3 * cd.getRatio("shaking") * shakePow;
		}

		game.scroller.x = MLib.fclamp(game.scroller.x, -level.wid*Const.GRID+wid, 0);
		game.scroller.y = MLib.fclamp(game.scroller.y, -level.hei*Const.GRID+hei, 0);
	}
}