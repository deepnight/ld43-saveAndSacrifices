package en.m;

class Demon extends en.Mob {
    public static var ALL : Array<Demon> = [];

    var tx = 0.;
    var ty = 0.;
    var wanderAng = 0.;

    public function new(x,y) {
        super(x,y);
        ALL.push(this);
        hasGravity = false;
        hasColl = false;
        frict = 0.94;
        spr.set("guy",0);
        spr.colorize(0xff3311);
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function pickTarget() {
        super.pickTarget();
        var dh = new DecisionHelper(Peon.ALL);
        dh.remove( function(e) return e.isInLight() || distCase(e)>=10 && !cd.has("aggro") );
        dh.remove( function(e) return Mob.anyoneHolds(e) && !e.cd.has("stillInteresting") );
        dh.score( function(e) return Mob.anyoneHolds(e) ? 2 : Mob.anyoneTargets(e) ? 2 : 0 );
        dh.score( function(e) return -distCase(e) );
        dh.score( function(e) return e.cd.has("targetPrio") ? 5 : 0 );
        target = dh.getBest();
        if( target!=null ) {
            cd.setS("keepTarget", rnd(2,4));
            // fx.markerEntity(target);
            fx.targetLine(this, target, 0xff0000);
            cd.setS("aggro", 6);
        }
    }

    override function onKick(by:Hero) {
        super.onKick(by);
        dy *= rnd(0.35,0.50);
        cd.setS("stun", rnd(0.9,1.1));
    }

    override function update() {
        // Lost target
        if( target!=null && !target.isAlive() )
            cancelTarget();

        if( target!=null && target.isInLight() )
            cancelTarget();

        // Forced to free target
        if( target!=null && isHoldingTarget && ( isUnconscious() || isInLight() ) ) {
            freeHoldedTarget();
            target.dx = rnd(0,0.1,true);
            target.dy = -rnd(0.05,0.08);
        }

        // Give up on a target already taken
        if( target!=null && !isHoldingTarget && Mob.anyoneHolds(target) && !target.cd.has("stillInteresting") )
            cancelTarget();

        // Pick another target eventually
        if( target!=null && !isHoldingTarget && !cd.has("keepTarget") )
            cancelTarget();

        super.update();

        // AI
        if( target!=null && !aiLocked() ) {
            // Fly away with target
            if( isHoldingTarget ) {
                tx = centerX+rnd(0,5,true);
                ty = centerY-30;
                if( !cd.hasSetS("flyUpLock",rnd(0.4,0.5)) )
                    lockAiS(rnd(0.3,0.4) * cd.getRatio("slowFlyStart"));
            }

            if( !Mob.anyoneHolds(target) ) {
                tx = target.centerX;
                ty = target.centerY;
            }

            // Fly around another demon holding target
            if( !isHoldingTarget && Mob.anyoneHolds(target) && !cd.hasSetS("wanderAroundLock", rnd(0.2, 0.3)) ) {
                var a = Math.atan2(target.centerY-centerY, target.centerX-centerX) + rnd(0,0.3,true);
                var d = rnd(18,30);
                tx = target.centerX - Math.cos(a) * d;
                ty = target.centerY - Math.sin(a) * d;
            }

            // Catch target!
            for(e in Peon.ALL)
                if( distPx(e)<=10 && !e.isInLight() && !Mob.anyoneHolds(e) && !e.cd.has("catchImmunity") ) {
                    target = e; // change mind if this wasn't the target
                    isHoldingTarget = true;
                    e.onCatchByMob(this);
                    e.cd.setS("stillInteresting", rnd(4,5));
                    lockAiS(1);
                    cd.setS("slowFlyStart", 6.5);
                    dy = level.hasColl(cx,cy) ? -rnd(0.18,0.19) : -rnd(0.11,0.12);
                    break;
                }
        }

        if( !aiLocked() && !isUnconscious() ) {
            if( target==null ) {
                tx = startPt.centerX;
                ty = startPt.centerY;
            }
            // Apply movement
            var a = Math.atan2(ty-centerY, tx-centerX);
            var s = 0.0030;
            dx+= Math.cos(a)*s*tmod;
            dy+= Math.sin(a)*s*tmod;

            var s = 0.0015;
            wanderAng += rnd(0.03,0.06) * tmod;
            dx+= Math.cos(wanderAng)*s*tmod;
            dy+= Math.sin(wanderAng)*s*tmod;
        }


        // Move target around
        if( isHoldingTarget ) {
            target.setPosPixel(footX+Math.cos(ftime*0.1)*2, footY+8);
        }
    }
}