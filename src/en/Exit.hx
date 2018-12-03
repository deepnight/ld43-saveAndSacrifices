package en;

class Exit extends Entity {
    public static var ALL : Array<Exit> = [];

    public var count = 0;
    var tf : h2d.Text;

    public function new(x,y) {
        super(x,y);
        spr.set("pixel");
        ALL.push(this);
        hasGravity = false;
        hasColl = false;

        tf = new h2d.Text(Assets.font);
        game.scroller.add(tf, Const.DP_BG);
        updateText();
    }

    public static function getSavedCount() {
        var n = 0;
        for(e in ALL)
            n+=e.count;
        return n;
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
        tf.remove();
    }

    function updateText() {
        tf.text = Std.string(count);
        tf.x = Std.int(centerX - tf.textWidth*0.5);
        tf.y = footY-Const.GRID*2-3-tf.textHeight;
    }

    override function update() {
        super.update();
        for(e in Peon.ALL)
            if( e.onGround && e.cx==cx && e.cy==cy && !Mob.anyoneHolds(e) ) {
                fx.fakeExitingPeon(e);
                count++;
                updateText();
                e.destroy();
            }
    }
}