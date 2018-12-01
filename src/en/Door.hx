package en;

class Door extends Entity {
    public static var ALL : Array<Door> = [];

    public var triggerId : Null<String>;
    var dWid = 1;
    var dHei = 1;

    public function new(x,y, w:Int, h:Int, ?triggerId:String) {
        super(x,y);
        ALL.push(this);
        this.triggerId = triggerId;
        dWid = w;
        dHei = h;
        hasGravity = false;
        hasColl = false;
        hei = Const.GRID;
        close();
    }

    public function close() {
        for(x in cx...cx+dWid)
        for(y in cy...cy+dHei)
            level.setColl(x,y, true);
        level.render();
    }

    public function open() {
        for(x in cx...cx+dWid)
        for(y in cy...cy+dHei)
            level.setColl(x,y, false);
        level.render();
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }
}