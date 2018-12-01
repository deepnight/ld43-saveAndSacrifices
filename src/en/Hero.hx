package en;

class Hero extends Entity {
    var ca(get,never) : mt.heaps.Controller.ControllerAccess; inline function get_ca() return Game.ME.ca;

    public function new() {
        super();
    }

    override function update() {
        super.update();
        if( ca.leftDown() ) dx-=0.08*tmod;
        if( ca.rightDown() ) dx+=0.08*tmod;
        if( onGround && ca.aDown() )
            dy = -0.4;
    }
}