package en;

class Spikes extends Entity {
    var active = true;
    public function new(x,y, triggerId:String) {
        super(x,y);
        hasGravity = false;
        hasColl = false;
        hei = Const.GRID;
    }

    override function update() {
        super.update();
        if( active )
            for(e in Peon.ALL)
                if( e.onGround && e.cx==cx && e.cy==cy-1 && MLib.fabs(e.xr-0.5)<=0.4 && !Mob.anyoneHolds(e) ) {
                    // active = false;
                    e.kill();
                }
    }
}