package en;

class Light extends Entity {
    public static var ALL : Array<Light> = [];
    public var active = false;
    var halo : HSprite;

    public function new(x,y, r:Float) {
        super(x,y);
        ALL.push(this);
        hasGravity = false;
        hasColl = false;
        radius = r;
        hei = 0;

        halo = Assets.gameElements.h_get("pixel");
        game.scroller.add(halo, Const.DP_FX_TOP);

        var g = new h2d.Graphics(halo);
        g.beginFill(0xffc900,0.03);
        g.lineStyle(1, 0xffc900, 0.10);
        g.drawCircle(0, 0, radius);

        turnOn();
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function postUpdate() {
        super.postUpdate();
        halo.setPosition(centerX, centerY);
        halo.visible = active;
    }

    public function turnOn() {
        active = true;
    }

    override function canBeKicked():Bool {
        return active;
    }

    override function onKick(by:Hero) {
        super.onKick(by);
        turnOff();
        dx*=0.5;
        hasGravity = true;
        hasColl = true;
    }

    override function checkLifters() {} // nope

    public function turnOff() {
        active = false;
    }

    override function update() {
        super.update();

        if( active && !cd.hasSetS("tick",0.1) ) {
            for(e in Entity.ALL)
                if( distPx(e) <= radius )
                    e.cd.setS("lighten", 0.15);
        }

        // if( !active )
        //     for(e in Hero.ALL)
        //         if( distPx(e)<=Const.GRID*2 )
        //             turnOn();
    }
}