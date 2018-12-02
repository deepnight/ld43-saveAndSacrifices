package en;

class Hero extends Entity {
    public static var ALL : Array<Hero> = [];

    var ca(get,never) : mt.heaps.Controller.ControllerAccess; inline function get_ca() return Game.ME.ca;
    public var active = false;
    var horizontalControl = 1.0;
    var grabbing = false;
    var wings : HSprite;
    var ring : HSprite;

    public function new(x,y) {
        super(x,y);
        ALL.push(this);
        lifter = true;

        wings = Assets.gameElements.h_get("wings",0, 0.5,1);
        game.scroller.add(wings, Const.DP_BG);
        wings.setPosition(footX, footY);
        wings.blendMode = Add;

        ring = Assets.gameElements.h_get("angelRing",0, 0.5,1);
        game.scroller.add(ring, Const.DP_BG);
        ring.setPosition(headX, headY);
        ring.blendMode = Add;

        spr.anim.registerStateAnim("heroIdle",0);
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
        wings.remove();
        ring.remove();
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
        wings.x += (footX-dir*2-wings.x)*0.4;
        wings.y += (footY-wings.y)*0.4;
        wings.scaleX = 1+Math.cos(ftime*0.035)*0.1;

        ring.x += (headX+dir-dir*2-ring.x)*0.3 + Math.cos(ftime*0.027)*0.5;
        ring.y += (headY-7-ring.y)*0.3 + Math.sin(ftime*0.021)*0.5;
        ring.rotation += Lib.angularSubstractionRad( -dir*0.1, ring.rotation )*0.2;

        spr.alpha = active ? 1 : 0.5;
        if( isLiftingSomeone() || level.hasColl(cx,cy) || level.hasColl(cx,cy-1) )
            spr.scaleX*=1.2;
        else
            spr.scaleY*=1.2;
    }

    override function canLift(e:Entity):Bool {
        return super.canLift(e) && !grabbing;
    }

    override function checkLifters() {
        if( !grabbing )
            super.checkLifters();
    }

    function grabAt(x,y) {
        setPosCase(x,y);
        grabbing = true;
        hasGravity = false;
        dx = dy = 0;
        xr = dir==1 && level.hasSpot("grabRight",cx,cy) ? 0.8 : 0.2;
        yr = 0.75;
        cd.setS("jumpLock",Const.INFINITE);
    }

    override function update() {
        if( grabbing )
            dx = dy = 0;

        super.update();

        if( active ) {
            if( onGround || grabbing )
                horizontalControl = 1;
            else
                horizontalControl*=Math.pow(0.99,tmod);

            // Walk
            if( !grabbing ) {
                var spd = 0.017;
                if( ca.leftDown() ) {
                    dx-=spd*tmod * horizontalControl * (ca.isGamePad()?-ca.lxValue():1);
                    dir = -1;
                }
                if( ca.rightDown() ) {
                    dx+=spd*tmod * horizontalControl * (ca.isGamePad()?ca.lxValue():1);
                    dir = 1;
                }
            }

            // Ledge grabbing & other traversal helpers
            if( dir==1 && level.hasSpot("grabRight",cx,cy) && dx>0 && dy>0 && xr>=0.6 && yr>=0.6 && !level.hasColl(cx+1,cy-1) )
                grabAt(cx,cy);
            if( dir==-1 && level.hasSpot("grabLeft",cx,cy) && dx<0 && dy>0 && xr<=0.4 && yr>=0.6 && !level.hasColl(cx-1,cy-1) )
                grabAt(cx,cy);
            if( dir==1 && level.hasSpot("grabRightUp",cx,cy) && dx>0 && dy>0 && xr>=0.7 && yr<=0.4 && !level.hasColl(cx,cy-1) && !level.hasColl(cx+1,cy-2) )
                grabAt(cx,cy-1);
            if( dir==-1 && level.hasSpot("grabLeftUp",cx,cy) && dx<0 && dy>0 && xr<=0.3 && yr<=0.4 && !level.hasColl(cx,cy-1) && !level.hasColl(cx-1,cy-2) )
                grabAt(cx,cy-1);
            // Ledge hopping
            if( !grabbing && level.hasSpot("grabLeft",cx,cy) && dx<0 && dy>0 && xr<=0.3 && yr<=0.3 && !cd.hasSetS("hopLimit",0.1) ) {
                // xr = MLib.fmin(xr, 0.1);
                xr = 0.1;
                yr = 0.1;
                dx = MLib.fmin(-0.15, dx);
                dy = -0.25;
            }
            if( !grabbing && level.hasSpot("grabRight",cx,cy) && dx>0 && dy>0 && xr>=0.7 && yr<=0.3 && !cd.hasSetS("hopLimit",0.1) ) {
                // xr = MLib.fmax(xr, 0.9);
                xr = 0.9;
                yr = 0.1;
                dx = MLib.fmax(0.15, dx);
                dy = -0.25;
            }

            // Double jump
            if( !grabbing && ca.aPressed() && !onGround && !cd.has("onGroundRecently") && !cd.has("doubleJumpLock") && !isLiftingSomeone() ) {
                dy = -0.35;
                cd.unset("extendJump");
                cd.setS("doubleJumpLock", Const.INFINITE);
            }
            if( onGround || grabbing )
                cd.unset("doubleJumpLock");

            // Jump
            if( ca.aDown() && !level.hasColl(cx,cy) )
                if( !cd.has("jumpLock") && ( grabbing || onGround || cd.has("onGroundRecently") ) ) {
                    dy = -0.35;
                    if( isLiftingSomeone() )
                        cd.unset("lifting");
                    if( grabbing ) {
                        hasGravity = true;
                        grabbing = false;
                    }
                    cd.unset("onGroundRecently");
                    cd.setS("extendJump", 0.12);
                    cd.unset("lifted");
                }
                else if( cd.has("extendJump") )
                    dy -= 0.037*tmod;

            if( !ca.aDown() )
                cd.unset("jumpLock");

            // Braking
            if( !ca.leftDown() && !ca.rightDown() )
                dx*=Math.pow(0.7,tmod);

            // Call peon
            if( ca.yPressed() && onGround ) {
                for(e in Peon.ALL)
                    e.goto(cx,cy);
            }

            // Kick
            if( ca.xPressed() ) {
                var dh = new DecisionHelper(Entity.ALL);
                dh.remove( function(e) return !e.isAlive() || distCase(e)>1.5 || !e.canBeKicked() );
                dh.score( function(e) return Std.is(e,Mob) ? ( e.as(Mob).isHoldingTarget ? 20 : 5 ) : 0);
                dh.score( function(e) return Std.is(e,Light) ? 2 : 0);
                dh.score( function(e) return -distCase(e) );
                dh.score( function(e) return dir==1 && e.centerX>=centerX-8 || dir==-1 && e.centerX<=centerX+8? 1 : 0 );
                var e = dh.getBest();
                if( e!=null ) {
                    e.dx = 0.5*dir;
                    e.dy = -0.35;
                    e.onKick(this);
                }
            }

            #if debug
            // Kill peon
            if( ca.dpadDownPressed() ) {
                for(e in Peon.ALL)
                    e.destroy();
            }
            #end
        }
    }
}