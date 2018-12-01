import mt.MLib;
import mt.deepnight.Lib;
import mt.heaps.slib.*;

class Entity {
    public static var ALL : Array<Entity> = [];
    public static var GC : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	// public var hero(get,never) : en.Hero; inline function get_hero() return Game.ME.hero;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	// public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var destroyed(default,null) = false;
	public var cd : mt.Cooldown;
	public var tmod : Float;

	public var uid : Int;
    public var cx = 0;
    public var cy = 0;
    public var xr = 0.5;
    public var yr = 1.0;

    public var dx = 0.;
    public var dy = 0.;
	public var frict = 0.82;
	public var gravity = 0.03;
	public var hasGravity = true;
	public var weight = 1.;
	public var hei = Const.GRID;
	public var radius = Const.GRID*0.5;

	public var dir(default,set) = 1;
	public var hasColl = true;
	public var isAffectBySlowMo = true;
	public var lastHitDir = 0;
	public var sprScaleX = 1.0;
	public var sprScaleY = 1.0;

    public var spr : HSprite;

	public var onGround(get,never) : Bool; inline function get_onGround() return level.hasColl(cx,cy+1) && yr>=1 && dy==0;

	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;
	public var centerX(get,never) : Float; inline function get_centerX() return footX;
	public var centerY(get,never) : Float; inline function get_centerY() return footY-radius;

    public function new(x:Int, y:Int) {
        uid = Const.NEXT_UNIQ;
        ALL.push(this);

		cd = new mt.Cooldown(Const.FPS);

        setPosCase(x,y);
        trace(this);

        spr = new HSprite();
        Game.ME.root.add(spr, Const.DP_MAIN);
        var g = new h2d.Graphics(spr);
        g.beginFill(0xff0000);
        g.drawRect(0,0,radius,hei);
        g.setPosition(-radius*0.5, -hei);
    }

	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
	}

	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
	}

    public inline function destroy() {
        if( !destroyed ) {
            destroyed = true;
            GC.push(this);
        }
    }

    public function dispose() {
        ALL.remove(this);
    }

    function onLand() {
        dy = 0;
    }
    function onTouchCeiling() {
    }

    function onTouchWall(wdir:Int) {
    }

    public function preUpdate(tmod:Float) {
        this.tmod = tmod;
    }
    public function postUpdate() {
        spr.x = (cx+xr)*Const.GRID;
        spr.y = (cy+yr)*Const.GRID;
        spr.scaleX = dir*sprScaleX;
        spr.scaleY = sprScaleY;
    }


    public function update() {
		// X
		var steps = MLib.ceil( MLib.fabs(dx*tmod) );
		var step = dx*tmod / steps;
		while( steps>0 ) {
			xr+=step;
			if( hasColl ) {
				if( xr>0.7 && level.hasColl(cx+1,cy) ) {
					xr = 0.7;
					onTouchWall(1);
					steps = 0;
				}
				if( xr<0.3 && level.hasColl(cx-1,cy) ) {
					xr = 0.3;
					onTouchWall(-1);
					steps = 0;
				}
			}
			while( xr>1 ) { xr--; cx++; }
			while( xr<0 ) { xr++; cx--; }
			steps--;
		}
		dx*=Math.pow(frict,tmod);

		// Gravity
		if( !onGround && hasGravity )
			dy += gravity*tmod;

		if( onGround )
			cd.setS("onGroundRecently",0.1);

		// Y
		var steps = MLib.ceil( MLib.fabs(dy*tmod) );
		var step = dy*tmod / steps;
		while( steps>0 ) {
			yr+=step;
			if( hasColl ) {
				if( yr>1 && level.hasColl(cx,cy+1) ) {
					yr = 1;
					onLand();
					steps = 0;
				}
				if( yr<0.3 && level.hasColl(cx,cy-1) ) {
					yr = 0.3;
					onTouchCeiling();
					steps = 0;
				}
			}
			while( yr>1 ) { yr--; cy++; }
			while( yr<0 ) { yr++; cy--; }
			steps--;
		}
		dy*=Math.pow(frict,tmod);
    }
}