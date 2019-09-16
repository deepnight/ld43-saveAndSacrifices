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
        hei = Const.GRID;

        halo = Assets.gameElements.h_get("pixel");
        game.scroller.add(halo, Const.DP_FX_TOP);

        spr.anim.registerStateAnim("lightOn",1, function() return active);
        spr.anim.registerStateAnim("lightOff",0);

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
        if( !onGround )
            spr.rotation += ( M.sign(dx)*0.22 - spr.rotation )*0.2;
        else
            spr.rotation = 0;

        if( active && !cd.hasSetS("fx",0.06) )
            fx.lightZone(centerX, centerY, radius, isLeftest() ? 0xffd500 : 0x29b5b4);

        if( !active && !cd.hasSetS("fx",0.06) ) {
            fx.candleSmoke(centerX, centerY-1);
            fx.candleSmoke(centerX-5, centerY-1);
            fx.candleSmoke(centerX+4, centerY+3);
        }
    }

    public function turnOn() {
        active = true;
    }

    override function canBeKicked():Bool {
        return active;
    }

    function isLeftest() {
        for(e in ALL)
            if( e!=this && e.isAlive() && e.active && e.cx<cx )
                return false;
        return true;
    }

    override function onKick(by:Hero) {
        super.onKick(by);

        if( !isLeftest() || ALL.length==1 ) {
            dx = dy = 0;
            new GameCinematic("illegalLight");
        }
        else {
            turnOff();
            dx*=0.3;
            dy*=0.2;
            hasGravity = true;
            hasColl = true;
        }
    }

    override function checkLifters() {} // nope

    public function turnOff() {
        active = false;
        fx.lightZoneOff(centerX, centerY, radius, 0xff0000);
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

