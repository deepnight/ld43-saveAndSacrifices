package en;

class Touchplate extends Entity {
    public var triggerId : Null<String>;

    public function new(x,y, triggerId:String) {
        super(x,y);
        this.triggerId = triggerId;
        hasGravity = false;
        hasColl = false;
        hei = Const.GRID;
    }

    override function update() {
        super.update();
        if( triggerId!=null )
            for(e in Hero.ALL)
                if( e.cx==cx && e.cy==cy && e.onGround ) {
                    trace("click!");
                    for(e in Door.ALL)
                        if( e.triggerId==triggerId )
                            e.open();
                    triggerId = null;
                }
    }
}