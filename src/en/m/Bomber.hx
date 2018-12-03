package en.m;

class Bomber extends en.Mob {
    public function new(x,y) {
        super(x,y);
    }

    override function onKick(by:Hero) {
        super.onKick(by);
        var p = 1 - Lib.distance(centerX,centerY, startPt.centerX, startPt.centerY) / (Const.GRID*2);
        if( cd.has("suiciding") )
            p = 0.3;
        dx *= 0.3*p;
        dy *= 0.3*p;
    }

    override function pickTarget() {
        super.pickTarget();
        var dh = new DecisionHelper(Peon.ALL);
        dh.remove( function(e) return !e.isAlive() || distCase(e)>8 || Mob.anyoneHolds(e) || !sightCheck(e) || e.cy!=cy );
        dh.score( function(e) return -distCase(e) );
        target = dh.getBest();
    }

    override function update() {
        super.update();

        if( !cd.has("suiciding") ) {
            if( target==null ) {
                // Come back to home
                if( onGround && startPt.distEntPx(this)>Const.GRID*0.5 && !cd.hasSetS("jump",0.4) ) {
                    dir = startPt.centerX>centerX ? 1 : -1;
                    dx = 0.1*dir;
                    dy = -rnd(0.15,0.20);
                }
            }
            else {
                // Run to target!
                dir = dirTo(target);
                dx += dir*0.01;

                // Platform end
                if( level.hasColl(cx+dir,cy) || !level.hasColl(cx+dir,cy+1) ) {
                    dx*=0.2;
                    cancelTarget();
                }

                // Near target
                if( target!=null && distCase(target)<=1 && !cd.has("trigger") ) {
                    cd.setS("trigger", 0.5);
                    cd.setS("suiciding", Const.INFINITE);
                    dx*=0.2;
                    dy*=0.2;
                }
            }
        }

        // Explodes
        if( cd.has("suiciding") && !cd.has("trigger") ) {
            fx.explosion(centerX, centerY, Const.GRID*3);
            game.viewport.shakeS(1);
            for(e in Peon.ALL)
                if( e.isAlive() && distCase(e)<=3 )
                    e.kill(this);
            for(e in Hero.ALL)
                if( distCase(e)<=5 ) {
                    e.dx = dirTo(e)*rnd(0.5,0.6);
                    e.dy = -rnd(0.3,0.4);
                }
            for(e in Cadaver.ALL)
                if( distCase(e)<=5 ) {
                    e.dx = dirTo(e)*rnd(0.6,0.8);
                    e.dy = -rnd(0.3,0.5);
                }
            kill(null);
        }
    }
}