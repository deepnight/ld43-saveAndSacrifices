package en;

class Cadaver extends Entity {
    public function new(e:Peon) {
        super(0,0);
        setPosPixel(e.footX, e.footY-1);
        hei = Const.GRID;
        spr.setRandom(e.isWorker() ? "workerDead" : "peonDead", Std.random);
    }

    override function postUpdate() {
        super.postUpdate();
    }

    override function update() {
        super.update();
    }
}