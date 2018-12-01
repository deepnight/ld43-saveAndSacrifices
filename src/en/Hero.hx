package en;

class Hero extends Entity {
    public static var ALL : Array<Hero> = [];

    var ca(get,never) : mt.heaps.Controller.ControllerAccess; inline function get_ca() return Game.ME.ca;
    public var active = false;

    public function new(x,y) {
        super(x,y);
        ALL.push(this);
        canLift = true;
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
        if( isLiftingSomeone() )
            spr.scaleX*=1.2;
        else
            spr.scaleY*=1.2;
    }

    override function update() {
        super.update();

        if( active ) {
            if( ca.leftDown() ) dx-=0.020*tmod;
            if( ca.rightDown() ) dx+=0.020*tmod;

            // Double jump
            if( ca.aPressed() && !onGround && !cd.has("onGroundRecently") && !cd.has("doubleJumpLock") && !isLiftingSomeone() ) {
                dy = -0.4;
                cd.unset("extendJump");
                cd.setS("doubleJumpLock", Const.INFINITE);
            }
            if( onGround )
                cd.unset("doubleJumpLock");

            // Jump
            if( ca.aDown() )
                if( !cd.has("jumpLock") && ( onGround || cd.has("onGroundRecently") ) ) {
                    if( isLiftingSomeone() ) {
                        dy = -0.06;
                        // pushLifteds(0,-0.07);
                        cd.setS("doubleJumpLock", Const.INFINITE);
                        cd.unset("extendJump");
                    }
                    else {
                        dy = -0.3;
                        if( isLifted() )
                            dy-=0.2;
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
        }
    }
}