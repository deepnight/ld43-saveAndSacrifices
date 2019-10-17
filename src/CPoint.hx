
import dn.Lib;

class CPoint {
	public var cx = 0;
	public var cy = 0;

	public var centerX(get,never) : Float; inline function get_centerX() return (cx+0.5)*Const.GRID;
	public var centerY(get,never) : Float; inline function get_centerY() return (cy+0.5)*Const.GRID;
	public var footX(get,never) : Float; inline function get_footX() return (cx+0.5)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+1)*Const.GRID;

	public function new(x,y) {
		cx = x;
		cy = y;
	}

	public function set(x,y) {
		cx = x;
		cy = y;
	}

	public function distEntCase(e:Entity) {
		return M.dist(e.cx+e.xr,e.cy+e.yr,cx+0.5,cy+0.5);
	}

	public function distEntPx(e:Entity) {
		return M.dist(e.centerX,e.centerY,centerX, centerY);
	}

}