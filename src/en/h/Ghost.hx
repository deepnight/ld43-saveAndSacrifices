package en.h;
class Ghost extends en.Hero {
    public function new(x,y) {
        super(x,y);
    }

    override function onTouchWall(wdir:Int) {
        super.onTouchWall(wdir);
        if( onGround && !level.hasColl(cx+wdir*2,cy) ) {
            dx = 0;
            cx+=wdir;
            xr = wdir==1 ? 0 : 1;
        }
    }

    override function xSpecialPhysics() {
        super.xSpecialPhysics();
        if( level.hasColl(cx,cy) )
            dx*=Math.pow(0.66,tmod);
    }

    override function update() {
        super.update();

        if( active && onGround ) {
            // Right
            if( level.hasColl(cx+1,cy) && !level.hasColl(cx+2,cy) )
                fx.wallGlow( (cx+1)*Const.GRID, (cy+1)*Const.GRID, 0x21357b, 1);
            if( !level.hasColl(cx+1,cy) && level.hasColl(cx+2,cy) && !level.hasColl(cx+3,cy) )
                fx.wallGlow( (cx+2)*Const.GRID, (cy+1)*Const.GRID, 0x21357b, 1);

            // Left
            if( level.hasColl(cx-1,cy) && !level.hasColl(cx-2,cy) )
                fx.wallGlow( cx*Const.GRID, (cy+1)*Const.GRID, 0x21357b, -1);
            if( !level.hasColl(cx-1,cy) && level.hasColl(cx-2,cy) && !level.hasColl(cx-3,cy) )
                fx.wallGlow( (cx-1)*Const.GRID, (cy+1)*Const.GRID, 0x21357b, -1);

            // Inside wall
            if( level.hasColl(cx,cy) ) {
                fx.wallGlow( cx*Const.GRID, (cy+1)*Const.GRID, 0x7b213f, -1);
                fx.wallGlow( (cx+1)*Const.GRID, (cy+1)*Const.GRID, 0x7b213f, 1);
            }
        }
    }
}