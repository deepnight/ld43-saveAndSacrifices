package en;

class Exit extends Entity {
    public static var ALL : Array<Exit> = [];

    public function new(x,y) {
        super(x,y);
        spr.set("pixel");
        ALL.push(this);
        hasGravity = false;
        hasColl = false;
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function update() {
        super.update();
        for(e in Peon.ALL)
            if( e.onGround && e.cx==cx && e.cy==cy && !Mob.anyoneHolds(e) ) {
                fx.fakeExitingPeon(e);
                e.destroy();
            }
    }
}