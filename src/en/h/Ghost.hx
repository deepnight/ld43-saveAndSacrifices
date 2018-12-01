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
}