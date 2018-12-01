class Level {
    public var wid : Int;
    public var hei : Int;
    public var collMap : Map<Int,Bool>;
    public function new() {
        wid = hei = 10;
        collMap = new Map();
    }

	public function isValid(cx:Float,cy:Float) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}

	public function coordId(x,y) return x+y*wid;

	public function hasColl(x:Int, y:Int) {
		return !isValid(x,y) ? true : collMap.get(coordId(x,y));
	}

	public function setColl(x,y,v:Bool) {
		collMap.set(coordId(x,y), v);
	}
}