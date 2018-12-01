import mt.deepnight.CdbHelper;

class Level extends mt.Process {
	public var lid : Data.RoomKind;
	public var infos(default,null) : Data.Room;
    public var wid(get,never) : Int; inline function get_wid() return infos.width;
    public var hei(get,never) : Int; inline function get_hei() return infos.height;
    public var collMap : Map<Int,Bool>;

    public function new(id:Data.RoomKind) {
		super(Game.ME);

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		lid = id;
		infos = Data.room.get(lid);
        collMap = new Map();
		for(m in infos.collisions)
			for(x in m.x...m.x+m.width)
			for(y in m.y...m.y+m.height)
				setColl(x,y, true);

		render();
    }

	public function render() {
		root.removeChildren();

		for(l in infos.layers) {
			var tileSet = infos.props.getTileset(Data.room, l.data.file);
			var tg = new h2d.TileGroup(Assets.levelTiles, root);

			for(t in CdbHelper.getLayerTiles(l.data, Assets.levelTiles, wid, tileSet))
				tg.add(t.x, t.y, t.t);
		}
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

	public function getMarker(id:Data.MarkerKind) {
		for(m in infos.markers)
			if( m.markerId==id )
				return new CPoint(m.x, m.y);
		return null;
	}

	public function getMarkers(id:Data.MarkerKind) : Array<CPoint> {
		var a = [];
		for(m in infos.markers)
			if( m.markerId==id )
				a.push( new CPoint(m.x, m.y) );
		return a;
	}
}