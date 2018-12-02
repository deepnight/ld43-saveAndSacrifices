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

        // var g = new h2d.Graphics(halo);
        // g.beginFill(0xffc900,0.03);
        // g.lineStyle(1, 0xffc900, 0.10);
        // g.drawCircle(0, 0, radius);

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
        if( active && !cd.hasSetS("fx",0.06) )
            fx.lightZone(centerX, centerY, radius, 0x29b5b4);
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

        if( active && !cd.hasSetS("tick",0.06) ) {
            for(e in Entity.ALL)
                if( distPx(e) <= radius ) {
                    if( !e.isInLight() )
                        fx.lightStatusChange(this, e, 0x29b5b4);
                    e.cd.setS("lighten", 0.10);

                    if( e.is(Mob) && !e.cd.hasSetS("lightPush",0.2) ) {
                        var a = Math.atan2(e.centerY-centerY, e.centerX-centerX);
                        var p = rnd(0.4,0.5);
                        e.dx*=Math.pow(0.8,tmod);
                        e.dy*=Math.pow(0.8,tmod);
                        e.dx+=Math.cos(a)*p*tmod;
                        e.dy+=Math.sin(a)*p*tmod;
                        fx.lightRepel(this, e, 0x297bb5);
                    }
                }
        }
    }
}

