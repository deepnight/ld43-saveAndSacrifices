import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);
        root.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		// Engine settings
		engine.backgroundColor = 0xff<<24|0x0;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		// Resources
		#if debug
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed({compressSounds:true});
        #end

        // Hot reloading
		#if debug
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.data.watch(function() {
            delayer.cancelById("cdb");

            delayer.addS("cdb", function() {
            	Data.load( hxd.Res.data.entry.getBytes().toString() );
				Game.ME.restartLevel();
            	if( Game.ME!=null )
                    Game.ME.onCdbReload();
            }, 0.2);
        });
		#end

		// Assets & data init
		Lang.init("en");
		Assets.init();
		Data.load( hxd.Res.data.entry.getText() );
		new dn.GameFocusHelper(Boot.ME.s2d, Assets.font);

		// Console
		new Console(Assets.font, s);

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.ENTER, Key.NUMPAD_ENTER);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);

		// Start
		delayer.addF(startGame, 1);
	}

	public function startGame() {
		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addS(function() {
				new Game();
			},0.1);
		}
		else
			new Game();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_HEIGHT>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEIGHT );
		root.setScale(Const.SCALE);
	}

    override function update() {
		SpriteLib.TMOD = tmod;
        super.update();
    }
}