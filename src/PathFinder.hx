class Node {
    public var id : Int;
    public var cx : Int;
    public var cy : Int;
    public var links : Array<Node>;

    public function new(id,x,y) {
        this.id = id;
        cx = x;
        cy = y;
        links = [];
    }

    public inline function toString() {
        return 'PathNode@$cx,$cy';
    }

    public function linkTo(n:Node, symetric:Bool) {
        if( n==null )
            throw "Linking "+this+" to null node";

        for(l in links)
            if( l==n )
                return;

        links.push(n);
        #if debug
        if( Console.ME.hasFlag("pf") )
            Game.ME.fx.markerFree(
                ((cx+0.5)*0.8+0.2*(n.cx+0.5))*Const.GRID,
                ((cy+0.5)*0.8+0.2*(n.cy+0.5))*Const.GRID,
                999., 0xffcc00
            );
        #end
        if( symetric )
            n.linkTo(this, false);
    }
}

class PathFinder {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

    var nodes : Map<Int, Node>;

    public function new() {
        nodes = new Map();
        for(cx in 0...level.wid)
        for(cy in 0...level.hei) {
            if( level.hasColl(cx,cy+1) && !level.hasColl(cx,cy) ) {
                var n = new Node(coordId(cx,cy), cx,cy);
                nodes.set( coordId(cx,cy), n );
            }
        }
        // Linking
        for(n in nodes) {
            if( hasNodeAt(n.cx-1, n.cy) )
                n.linkTo( getNodeAt(n.cx-1, n.cy), true );

            if( hasNodeAt(n.cx+1, n.cy) )
                n.linkTo( getNodeAt(n.cx+1, n.cy), true );

            // Small jumps
            if( hasNodeAt(n.cx+1, n.cy-1) && !level.hasColl(n.cx,n.cy-1) )
                n.linkTo( getNodeAt(n.cx+1, n.cy-1), false );

            if( hasNodeAt(n.cx-1, n.cy-1) && !level.hasColl(n.cx,n.cy-1) )
                n.linkTo( getNodeAt(n.cx-1, n.cy-1), false );

            // High jumps
            if( hasNodeAt(n.cx+1, n.cy-2) && !level.hasColl(n.cx,n.cy-1) && !level.hasColl(n.cx,n.cy-2) )
                n.linkTo( getNodeAt(n.cx+1, n.cy-2), false );

            if( hasNodeAt(n.cx-1, n.cy-2) && !level.hasColl(n.cx,n.cy-1) && !level.hasColl(n.cx,n.cy-2) )
                n.linkTo( getNodeAt(n.cx-1, n.cy-2), false );

            // Falls
            if( !level.hasColl(n.cx+1,n.cy) && !level.hasColl(n.cx+1,n.cy+1) ) {
                var x = n.cx+1;
                var y = n.cy+1;
                while( !hasNodeAt(x,y) )
                    y++;
                n.linkTo( getNodeAt(x,y), false );
            }
            if( !level.hasColl(n.cx-1,n.cy) && !level.hasColl(n.cx-1,n.cy+1) ) {
                var x = n.cx-1;
                var y = n.cy+1;
                while( !hasNodeAt(x,y) )
                    y++;
                n.linkTo( getNodeAt(x,y), false );
            }
        }
    }

    inline function hasNodeAt(cx,cy) {
        return isValid(cx,cy) && nodes.exists( coordId(cx,cy) );
    }

    inline function getNodeAt(cx,cy) : Null<Node> {
        return !isValid(cx,cy) ? null : nodes.get( coordId(cx,cy) );
    }

    inline function isValid(x:Int,y:Int) return level.isValid(x,y);
    inline function coordId(x:Int,y:Int) return level.coordId(x,y);

    inline function getHeuristicDist(n:Node, target:Node) {
        return Lib.distanceSqr(n.cx, n.cy, target.cx, target.cy);
    }

    public function getPath(fx:Int, fy:Int, tx:Int, ty:Int) {
        var start = getNodeAt(fx,fy);
        var target = getNodeAt(tx,ty);
        var path = [];

        if( start==null || target==null )
            return path;
        exploreRec(start, start, target, new Map(), path);
        path.reverse();
        #if debug
        if( Console.ME.hasFlag("pf") )
            for(n in path)
                this.fx.markerCase(n.cx, n.cy, 1, 0xffff00);
        #end
        return path;
    }

    inline function pickBestNext(cur:Node, target:Node, closeds:Map<Int,Bool>) {
        var bestNext = null;
        for(n in cur.links) {
            if( !closeds.exists(n.id) && ( bestNext==null || getHeuristicDist(n, target) < getHeuristicDist(bestNext, target) ) )
                bestNext = n;
        }
        return bestNext;
    }

    function exploreRec(start:Node, cur:Node, target:Node, closeds:Map<Int, Bool>, path:Array<Node>) : Bool {
        closeds.set(cur.id, true);

        #if debug
        if( Console.ME.hasFlag("pf") )
            for(n in path)
                fx.markerCase(cur.cx, cur.cy, 0.2, 0xff0000);
        #end

        if( cur==target ) {
            // Reached target!
            path.push(target);
            return true;
        }

        // Explore next links
        var bestNext = pickBestNext(cur, target, closeds);
        while( bestNext!=null ) {
            if( exploreRec(start, bestNext, target, closeds, path) ) {
                path.push(cur);
                return true;
            }
            bestNext = pickBestNext(cur, target, closeds);
        }

        return false;
    }
}