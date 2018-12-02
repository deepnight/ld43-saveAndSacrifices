package en;

class Peon extends Entity {
    public static var ALL : Array<Peon> = [];

    var grabbing = false;
    var speed = 1.0;
    var target : Null<CPoint>;
    var targetXr = 0.5;
    var path : Array<PathFinder.Node>;
    var dumbMode = true;

    public function new(x,y) {
        super(x,y);
        ALL.push(this);
        hei = Const.GRID;
        spr.set("guy",1);
        speed = rnd(0.9,1);
        // lifter = true;
        path = [];
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    public function goto(x,y) {
        path = level.pf.getPath(cx,cy, x,y);
        if( path.length>1 ) {
            dumbMode = false;
            path.shift();
            target = new CPoint(path[0].cx, path[0].cy);
            path.shift();
        }
        else {
            dumbMode = true;
            target = new CPoint(x,y);
        }
    }

    function grabAt(x,y) {
        setPosCase(x,y);
        grabbing = true;
        hasGravity = false;
        dx = dy = 0;
        xr = level.hasSpot("grabRight",cx,cy) ? 0.8 : 0.2;
        yr = 0.75;
        cd.setS("maintainGrab", rnd(0.4, 0.6));
    }


    override function checkLifters() {
        if( !grabbing )
            super.checkLifters();
    }

    override function update() {
        if( !grabbing && target!=null ) {
            // Seek target
            if( !cd.has("walkLock") ) {
                var s = speed * 0.008 * (onGround?1:0.5) * ( isLiftingSomeone() ? 0.3 : 1);
                if( target.cx>cx || target.cx==cx && xr<0.5 ) {
                    dir = 1;
                    dx+=s*tmod;
                }
                if( target.cx<cx || target.cx==cx && xr>0.5 ) {
                    dir = -1;
                    dx-=s*tmod;
                }
            }

            // Jump (dumb mode)
            if( dumbMode && onGround && level.hasColl(cx+dir, cy) && ( dir==1 && xr>=0.7 || dir==-1 && xr<=0.3 ) && !cd.hasSetS("jump",rnd(0.3,0.7)) ) {
                dy = -0.21;
                dx = 0.2*dir;
                cd.setS("jumping", 0.10);
            }

            if( !dumbMode ) {
                // Normal jump
                if( onGround && target.cy==cy-1 && ( dir==1 && xr>=0.7 || dir==-1 && xr<=0.3 ) && !cd.hasSetS("jump",rnd(0.3,0.7)) ) {
                    dy = -0.21;
                    dx = 0.2*dir;
                    cd.unset("walkLock");
                    cd.setS("jumping", 0.10);
                }

                // High jump
                if( onGround && target.cy<cy-1 && ( dir==1 && xr>=0.6 || dir==-1 && xr<=0.4 ) && !cd.hasSetS("jump",rnd(0.2,0.4)) ) {
                    dy = -0.21;
                    dir = target.cx<cx ? -1 : 1;
                    cd.setS("walkLock", 1);
                    cd.setS("jumping", 0.10);
                }
            }

            // Give up on impossible situations in Dumb Mode
            if( dumbMode && target.cx==cx && target.cy<cy )
                target = null;

            // Pick next point in path
            if( target!=null && cx==target.cx && cy==target.cy && MLib.fabs(xr-0.5)<=0.1 ) {
                if( path.length==0 )
                    target = null;
                else {
                    var next = path.shift();
                    target.set( next.cx, next.cy );
                }
            }

            #if debug
            if( Console.ME.hasFlag("pf") && target!=null )
                fx.markerCase(target.cx, target.cy, 0.2, 0x990000);
            #end
        }
        else if( !grabbing ) {
            // Wander
            if( !cd.hasSetS("wander", rnd(0.7,1)) )
                targetXr = rnd(0.1,0.9);
            if( isLiftingSomeone() )
                targetXr = xr;
             var s = speed * 0.004 * (onGround?1:0.5);
            if( MLib.fabs(xr-targetXr)>=0.1 ) {
                if( targetXr>xr ) {
                    dir = 1;
                    dx+=s*tmod;
                }
                if( targetXr<xr ) {
                    dir = -1;
                    dx-=s*tmod;
                }
            }
        }

        // Jump extra
        if( !onGround && cd.has("jumping") )
            dy-=0.042*tmod;

        super.update();

        // Ledge grabbing
        if( dumbMode || target!=null && target.cy<cy ) {
            if( level.hasSpot("grabRight",cx,cy) && dx>0 && dy>0 && xr>=0.6 && yr>=0.6 && !level.hasColl(cx+1,cy-1) )
                grabAt(cx,cy);
            if( level.hasSpot("grabLeft",cx,cy) && dx<0 && dy>0 && xr<=0.4 && yr>=0.6 && !level.hasColl(cx-1,cy-1) )
                grabAt(cx,cy);
            if( level.hasSpot("grabRightUp",cx,cy) && dx>0 && dy>0 && xr>=0.7 && yr<=0.4 && !level.hasColl(cx,cy-1) && !level.hasColl(cx+1,cy-2) )
                grabAt(cx,cy-1);
            if( level.hasSpot("grabLeftUp",cx,cy) && dx<0 && dy>0 && xr<=0.3 && yr<=0.4 && !level.hasColl(cx,cy-1) && !level.hasColl(cx-1,cy-2) )
                grabAt(cx,cy-1);
        }

        // Leave grab
        if( grabbing && !cd.has("maintainGrab") ) {
            grabbing = false;
            hasGravity = true;
            dx = dir*0.16;
            dy = -0.17;
            cd.setS("jumping", 0.15);
        }
    }
}