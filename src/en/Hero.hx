package en;

class Hero extends Entity {
    public static var ALL : Array<Hero> = [];

    var ca(get,never) : mt.heaps.Controller.ControllerAccess; inline function get_ca() return Game.ME.ca;
    public var active = false;

    public function new(x,y) {
        super(x,y);
        ALL.push(this);
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
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
    }

    override function update() {
        super.update();

        if( active ) {
            if( ca.leftDown() ) dx-=0.03*tmod;
            if( ca.rightDown() ) dx+=0.03*tmod;

            // Double jump
            if( ca.aPressed() && !onGround && !cd.has("onGroundRecently") && !cd.has("doubleJumpLock") ) {
                dy = -0.5;
                cd.setS("doubleJumpLock", Const.INFINITE);
            }
            if( onGround )
                cd.unset("doubleJumpLock");

            // Jump
            if( ca.aDown() )
                if( !cd.has("jumpLock") && ( onGround || cd.has("onGroundRecently") ) ) {
                    dy = -0.3;
                    cd.unset("onGroundRecently");
                    cd.setS("extendJump", 0.15);
                }
                else if( cd.has("extendJump") ) {
                    dy-=0.037;
                }

            if( !ca.aDown() )
                cd.unset("jumpLock");
        }
    }
}