package en;

class Spikes extends Entity {
    var active = true;
    public function new(x,y, triggerId:String) {
        super(x,y);
        hasGravity = false;
        hasColl = false;
        hei = Const.GRID;
        spr.setRandom("spikes", Std.random);
    }

    override function postUpdate() {
        super.postUpdate();
    }

    override function update() {
        super.update();
        if( active )
            for(e in Peon.ALL)
                if( e.yr>=0.8 && e.cx==cx && e.cy==cy && M.fabs(e.xr-0.5)<=0.4 && !Mob.anyoneHolds(e) ) {
                    // active = false;
                    e.kill(this);
                }
    }
}