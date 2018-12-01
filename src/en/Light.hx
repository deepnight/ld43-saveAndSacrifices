package en;

class Light extends Entity {
    public static var ALL : Array<Light> = [];
    public var active = false;
    var halo : HSprite;

    public function new(xx:Float,yy:Float, r:Float) {
        super(0,0);
        ALL.push(this);
        setPosPixel(xx,yy);
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
        level.rebuildLightMap();
    }

    public function turnOff() {
        active = false;
        level.rebuildLightMap();
    }

    override function update() {
        super.update();
        if( active ) {
            // for(e in Hero.ALL)
            //     if( distPx(e) <= radius )
            //     // if( Lib.distance(centerX, centerY, e.centerX, e.centerY) <= radius )
            //         e.cd.setS("inLight", 0.1);
        }
        else {
            for(e in Hero.ALL)
                if( distPx(e)<=Const.GRID*2 )
                    turnOn();
        }
    }
}