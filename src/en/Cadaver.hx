package en;

class Cadaver extends Entity {
    public static var ALL : Array<Cadaver> = [];
    public function new(e:Peon) {
        super(0,0);
        ALL.push(this);
        setPosPixel(e.footX, e.footY-1);
        hei = Const.GRID;
        frict = 0.92;
        spr.setRandom(e.isWorker() ? "workerDead" : "peonDead", Std.random);
    }

    override function checkLifters() { // nope
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }
}