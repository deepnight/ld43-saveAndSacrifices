import mt.deepnight.CdbHelper;

class Level extends mt.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var lid : Data.RoomKind;
	public var infos(default,null) : Data.Room;
    public var wid(get,never) : Int; inline function get_wid() return infos.width;
    public var hei(get,never) : Int; inline function get_hei() return infos.height;
    public var collMap : Map<Int,Bool>;
	public var pf : PathFinder;
	var spots : Map<String, Map<Int,Bool>>;

    public function new(id:Data.RoomKind) {
		super(Game.ME);

		Game.ME.level = this;
		lid = id;
		infos = Data.room.get(lid);

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		// Init collisions
        collMap = new Map();
		for(l in infos.layers) {
			if( l.name=="collisions" )
				for(t in CdbHelper.getLayerPoints(l.data, wid))
					setColl(t.cx, t.cy, true);
		}
		// for(m in infos.collisions)
		// 	for(x in m.x...m.x+m.width)
		// 	for(y in m.y...m.y+m.height)
		// 		setColl(x,y, true);


		// Spots
		spots = new Map();
		for(cx in 0...wid)
		for(cy in 0...hei) {
			if( hasColl(cx,cy) && !hasColl(cx,cy-1) ) {
				if( !hasColl(cx-1,cy) && !hasColl(cx-1,cy+1) ) {
					addSpot("grabRight",cx-1,cy);
					addSpot("grabRightUp",cx-1,cy+1);
				}
				if( !hasColl(cx+1,cy) && !hasColl(cx+1, cy+1) ) {
					addSpot("grabLeft",cx+1,cy);
					addSpot("grabLeftUp",cx+1,cy+1);
				}
			}
		}

		pf = new PathFinder();

		// Attach entities
		for(m in infos.markers)
			switch( m.markerId ) {
				case Hero1 :
					game.hero = new en.h.Ghost(m.x, m.y);
					game.hero.activate();

				case Hero2 :
					// game.hero2 = new en.Hero(m.x, m.y);

				case Hero3 :
					// game.hero3 = new en.Hero(m.x, m.y);

				case Light :
					new en.Light(m.x, m.y, 5*Const.GRID);
					// new en.Light((m.x+m.width*0.5)*Const.GRID, (m.y+m.height*0.5)*Const.GRID, MLib.fmax(m.width, m.height)*Const.GRID*0.5);

				case Door :
					new en.Door(m.x, m.y, m.width, m.height, m.id);

				case Touchplate :
					new en.Touchplate(m.x, m.y, m.id);

				case Spikes :
					for(cx in m.x...m.x+m.width)
						new en.Spikes(cx, m.y, m.id);

				case Peon :
					new en.Peon(m.x, m.y);

				case Demon :
					new en.m.Demon(m.x, m.y);
			}

		render();
    }

	public function render() {
		root.removeChildren();

		// #if debug
		var g = new h2d.Graphics(root);
		for(cx in 0...wid)
		for(cy in 0...hei)
			if( hasColl(cx,cy) ) {
				g.beginFill(0xff0000,0.8);
				g.drawRect(cx*Const.GRID, cy*Const.GRID, Const.GRID, Const.GRID);
			}
		// #end

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

	public function coordId(x:Int,y:Int) return x+y*wid;

	public function hasColl(x:Int, y:Int) {
		return !isValid(x,y) ? true : collMap.get(coordId(x,y));
	}

	public function setColl(x,y,v:Bool) {
		collMap.set(coordId(x,y), v);
	}

	public function addSpot(k:String, cx:Int, cy:Int) {
		if( !isValid(cx,cy) )
			throw "Invalid spot "+k+" at "+cx+","+cy;

		if( !spots.exists(k) )
			spots.set(k, new Map());
		spots.get(k).set(coordId(cx,cy), true);
	}

	public inline function hasSpot(k, cx,cy) {
		return spots.exists(k) && spots.get(k).get(coordId(cx,cy))==true;
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

	override function postUpdate() {
		super.postUpdate();

		// if( !cd.hasSetS("darkness",0.5) ) {
		// 	for( cx in 0...wid)
		// 	for( cy in 0...hei)
		// 		if( !hasLight(cx,cy) )
		// 			fx.darkness((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID, 0x121118);
		// }
	}

	override function update() {
		super.update();
	}
}