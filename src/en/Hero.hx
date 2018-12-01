package en;

class Hero extends Entity {
    public static var ALL : Array<Hero> = [];

    var ca(get,never) : mt.heaps.Controller.ControllerAccess; inline function get_ca() return Game.ME.ca;
    public var active = false;
    var horizontalControl = 1.0;
    var grabbing = false;

    public function new(x,y) {
        super(x,y);
        ALL.push(this);
        lifter = true;
        spr.set("guy",1);
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    public function deactivate() {
        if( !active )
            return;

        active = false;
        dx*=0.25;
    }

    public function activate() {
        for(e in ALL)
            e.active = false;
        active = true;
    }

    override function onLand() {
        super.onLand();
        cd.setS("jumpLock",Const.INFINITE);
    }

    override function postUpdate() {
        super.postUpdate();
        spr.alpha = active ? 1 : 0.5;
        if( isLiftingSomeone() || level.hasColl(cx,cy) || level.hasColl(cx,cy-1) )
            spr.scaleX*=1.2;
        else
            spr.scaleY*=1.2;
    }

    override function canLift(e:Entity):Bool {
        return super.canLift(e) && !grabbing;
    }

    function grabAt(x,y) {
        setPosCase(x,y);
        grabbing = true;
        hasGravity = false;
        dx = dy = 0;
        xr = level.hasSpot("grabRight",cx,cy) ? 0.8 : 0.2;
        yr = 0.75;
        cd.setS("jumpLock",Const.INFINITE);
    }

    override function update() {
        super.update();

        if( active ) {
            if( onGround || grabbing )
                horizontalControl = 1;
            else
                horizontalControl*=Math.pow(0.99,tmod);

            // Walk
            if( !grabbing ) {
                if( ca.leftDown() ) {
                    dx-=0.020*tmod * horizontalControl * -ca.lxValue();
                    dir = -1;
                }
                if( ca.rightDown() ) {
                    dx+=0.020*tmod * horizontalControl * ca.lxValue();
                    dir = 1;
                }
            }

            // Ledge grabbing & other traversal helpers
            if( level.hasSpot("grabRight",cx,cy) && dx>0 && dy>0 && xr>=0.6 && yr>=0.6 && !level.hasColl(cx+1,cy-1) )
                grabAt(cx,cy);
            if( level.hasSpot("grabLeft",cx,cy) && dx<0 && dy>0 && xr<=0.4 && yr>=0.6 && !level.hasColl(cx-1,cy-1) )
                grabAt(cx,cy);
            if( level.hasSpot("grabRightUp",cx,cy) && dx>0 && dy>0 && xr>=0.7 && yr<=0.4 && !level.hasColl(cx,cy-1) && !level.hasColl(cx+1,cy-2) )
                grabAt(cx,cy-1);
            if( level.hasSpot("grabLeftUp",cx,cy) && dx<0 && dy>0 && xr<=0.3 && yr<=0.4 && !level.hasColl(cx,cy-1) && !level.hasColl(cx-1,cy-2) )
                grabAt(cx,cy-1);
            // Ledge hopping
            if( !grabbing && level.hasSpot("grabLeft",cx,cy) && dx<0 && dy>0 && xr<=0.5 && yr<=0.3 && !cd.hasSetS("hopLimit",0.1) ) {
                xr = MLib.fmin(xr, 0.2);
                dy = -0.25;
            }
            if( !grabbing && level.hasSpot("grabRight",cx,cy) && dx>0 && dy>0 && xr>=0.5 && yr<=0.3 && !cd.hasSetS("hopLimit",0.1) ) {
                xr = MLib.fmax(xr, 0.8);
                dy = -0.25;
            }

            // Double jump
            if( !grabbing && ca.aPressed() && !onGround && !cd.has("onGroundRecently") && !cd.has("doubleJumpLock") && !isLiftingSomeone() ) {
                dy = -0.3;
                cd.unset("extendJump");
                cd.setS("doubleJumpLock", Const.INFINITE);
            }
            if( onGround || grabbing )
                cd.unset("doubleJumpLock");

            // Jump
            if( ca.aDown() && !level.hasColl(cx,cy) )
                if( !cd.has("jumpLock") && ( grabbing || onGround || cd.has("onGroundRecently") ) ) {
                    if( isLiftingSomeone() ) {
                        dy = -0.06;
                        // pushLifteds(0,-0.07);
                        cd.setS("doubleJumpLock", Const.INFINITE);
                        cd.unset("extendJump");
                    }
                    else {
                        dy = -0.3;
                        // if( isLifted() )
                            // dy-=0.1;
                        if( grabbing ) {
                            hasGravity = true;
                            grabbing = false;
                        }
                        cd.unset("onGroundRecently");
                        cd.setS("extendJump", 0.1);
                        cd.unset("lifted");
                    }
                }
                else if( cd.has("extendJump") )
                    dy -= 0.037*tmod;

            if( !ca.aDown() )
                cd.unset("jumpLock");

            // Braking
            if( !ca.leftDown() && !ca.rightDown() )
                dx*=Math.pow(0.7,tmod);

            if( ca.bDown() )
                game.fx.markerCase(cx,cy);
        }
    }
}