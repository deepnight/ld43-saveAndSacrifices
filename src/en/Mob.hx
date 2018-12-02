package en;

class Mob extends Entity {
    public static var ALL : Array<Mob> = [];

    var startPt : CPoint;
    public var target : Null<Peon>;
    public var isHoldingTarget = false;

    function new(x,y) {
        super(x,y);
        ALL.push(this);
        startPt = new CPoint(cx,cy);
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function canBeKicked():Bool {
        return true;
    }

    public static function anyoneHolds(e:Peon) {
        for(m in ALL)
            if( m.target==e && m.isHoldingTarget )
                return true;
        return false;
    }

    public static function anyoneTargets(e:Peon) {
        for(m in ALL)
            if( m.target==e )
                return true;
        return false;
    }

    public inline function lockAiS(t:Float) cd.setS("aiLock",t);
    public inline function aiLocked() return cd.has("aiLock") || cd.has("stun");
    public inline function isUnconscious() return cd.has("stun");

    function pickTarget() {}

    override function update() {
        super.update();

        if( target==null && !cd.hasSetS("targetPickLock",0.25) )
            pickTarget();
    }
}