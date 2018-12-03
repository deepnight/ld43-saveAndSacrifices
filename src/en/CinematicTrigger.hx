package en;

class CinematicTrigger extends Entity {
    public static var ALL : Array<CinematicTrigger> = [];
    var marker : Data.Room_markers;

    public function new(x,y, m:Data.Room_markers) {
        super(x,y);
        marker = m;
        spr.set("pixel");
        ALL.push(this);
        hasGravity = false;
        hasColl = false;
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
        marker = null;
    }

    override function update() {
        super.update();

        for(e in Hero.ALL)
            if( e.cx>=marker.x && e.cx<marker.x+marker.width && e.cy>=marker.y && e.cy<marker.y+marker.height ) {
                #if !debug
                new GameCinematic(marker.id.toLowerCase());
                #end
                destroy();
                break;
            }
    }
}