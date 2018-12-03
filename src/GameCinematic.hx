class GameCinematic extends mt.Process {
    public static var ALL : Array<GameCinematic> = [];
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
    var cm : mt.deepnight.Cinematic;

    public function new(cid:String) {
        super(game);
        ALL.push(this);
        cm = new mt.deepnight.Cinematic(Const.FPS);

        cd.setS("skipLock",0.6);
        var ctrlCol = 0x24976b;
        switch( cid ) {
            case "intro" :
                cm.create({
                    popText("\"SAVE & SACRIFICE\"\n\nA 48h game by Sebastien Benard (www.deepnight.net)\n\nPress SPACE (keyboard) or A (gamepad) to continue.");
                    end;
                    complete();
                });

            case "fly" :
                cm.create({
                    popText("Press UP (keyboard) or A (gamepad) to jump and use your wings.", ctrlCol);
                    end;
                    popText("How cool is that?");
                    end;
                    complete();
                });

            case "spikes" :
                cm.create({
                    popText("As the Supreme Lord Commander of Heavens, spikes are no threat to you.");
                    end;
                    popText("Just ignore them and go on.");
                    end;
                    complete();
                });

            case "peons" :
                cm.create({
                    popText("Those idiots over there are your 'lost sheeps'.");
                    end;
                    popText("You should keep them alive.");
                    end;
                    popText("Well, actually, your goal is only to SAVE AT LEAST ONE of them.", 0xbb0000);
                    end;
                    popText("You might need to SACRIFICE some of these simpletons for the greater good.");
                    end;
                    complete();
                });

            case "light1" :
                cm.create({
                    popText("You can kick stuff using SPACE (keyboard) or X (gamepad).", ctrlCol);
                    end;
                    popText("Kick sheeps to move them around.");
                    end;
                    popText("Or you kick the CANDLE to force all of them to run to the next candle on the right.");
                    showCoord("candle");
                    end;
                    complete();
                });

            case "light2" :
                cm.create({
                    popText("Demons hate the Light. They cannot approach as long as the candle is on.");
                    end;
                    popText("They can't kill you, but they can kill your sheeps.", 0xbb0000);
                    end;
                    popText("Nothing a good kick in the ass can solve.");
                    end;
                    complete();
                });

            case "high" :
                cm.create({
                    popText("Sometime, a little help is needed.");
                    end;
                    popText("Stand still NEAR the wall, your sheeps will climb on you.", ctrlCol);
                    showCoord("wall");
                    end;
                    complete();
                });

            case "bomber" :
                cm.create({
                    popText("It might be a wise idea to send someone as a scout over there.");
                    showCoord("scout");
                    end;
                    complete();
                });

            case "lost" :
                cm.create({
                    popText("All your sheep are deads. You FAILED.", 0xee0000);
                    end;
                    game.restartLevel();
                    complete();
                });

            case "levelComplete" :
                var saved = en.Exit.getSavedCount();
                var killed = level.getMarkers(Peon).length - saved;
                cm.create({
                    if( killed==0 )
                        popText("You saved everyone in this area!", 0x5c9347);
                    else if( killed==1 )
                        popText("You sacrified one single sheep to save all the others. Not bad.");
                    else
                        popText("You sacrified "+killed+" sheeps to save "+saved+" others. You're a monster.", 0xee0000);
                    end;
                    game.nextLevel();
                    complete();
                });

            case "credits" :
                cm.create({
                    popText("Thank you for playing :)");
                    end;
                    popText("This game was created in 48h for the Ludum Dare 46. The theme was 'Sacrifices must be made'.");
                    end;
                    popText("It's a rather short entry, I hope you liked it anyway!");
                    end;
                    popText("Find more games I made on www.deepnight.net");
                    end;
                    game.cd.setS("gameEndLock", 30);
                    complete();
                });

            case "illegalLight" :
                cm.create({
                    popText("You cannot turn off this candle for now.", 0xbb0000);
                    end;
                    complete();
                });

            case _ :
                cm.create({
                    popText("UNKNOWN CINEMATIC "+cid, 0xff0000);
                    end;
                    complete();
                });
        }
    }

    function showCoord(id:String, ?t:Float) {
        fx.showCoord( level.getMarker(FreeMarker,id).cx, level.getMarker(FreeMarker,id).cy, t );
    }

    function complete() {
        clearText();
        delayer.addS(destroy, 0.3);
    }

    var curText : Null<h2d.Flow>;
    function clearText() {
        if( curText!=null ) {
            var f = curText;
            curText = null;
            tw.createS(f.x, f.x+20, 0.2);
            tw.createS(f.alpha, 0, 0.2).end( function() f.remove() );
        }
    }
    function popText(str:String, ?c=0x282a32) {
        clearText();
        var f = new h2d.Flow();
        curText = f;
        Main.ME.root.add(f, Const.DP_UI);
        // f.backgroundTile = Assets.gameElements.getTile("dialog");
        f.borderWidth = 4;
        f.borderHeight = 4;
        f.isVertical = true;
        f.padding = 8;

        var bg = new h2d.ScaleGrid(Assets.gameElements.getTile("dialog"), 4,4, f);
        f.getProperties(bg).isAbsolute = true;
        bg.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(c);

        f.onAfterReflow = function() {
            bg.width = f.outerWidth;
            bg.height = f.outerHeight;
        }

        var tf = new h2d.Text(Assets.font, f);
        tf.text = str;
        tf.maxWidth = 190;
        tf.textColor = 0xffffff;

        f.x = Std.int( w()/Const.SCALE * 0.5 - f.outerWidth*0.5 + rnd(0,30,true) );
        f.y = rnd(20,40);

        tw.createS(f.x, f.x-20>f.x, 0.2);
        // tw.createS(tf.scaleY, 0>1, 0.12);
        cd.setS("skipLock", 0.2);
    }

    override function onDispose() {
        super.onDispose();
        cm.destroy();
        cm = null;
        ALL.remove(this);
        if( curText!=null )
            curText.remove();
    }

    public static function hasAny() return ALL.length>0;

    override function update() {
        cm.update(dt);
        super.update();

        if( game.ca.aPressed() || game.ca.bPressed() || game.ca.xPressed() )
            if( curText!=null && !cd.has("skipLock") ) {
                cm.signal();
                clearText();
            }
    }
}