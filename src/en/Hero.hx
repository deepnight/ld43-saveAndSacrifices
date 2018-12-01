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

    override function update() {
        super.update();

        if( active ) {
            if( ca.leftDown() ) dx-=0.03*tmod;
            if( ca.rightDown() ) dx+=0.03*tmod;
            if( !cd.has("jumpLock") && ( onGround || cd.has("onGroundRecently") ) && ca.aDown() ) {
                cd.unset("onGroundRecently");
                dy = -0.6;
                cd.setS("jumpLock",Const.INFINITE);
            }
            if( !ca.aDown() )
                cd.unset("jumpLock");
        }
    }
}