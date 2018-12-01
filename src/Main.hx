import mt.Process;
import mt.MLib;
import Data;
import mt.heaps.GamePad;
import hxd.Key;

class Main extends mt.Process {
	public static var ME : Main;
	public var controller : mt.heaps.Controller;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);
        root.scale(6);
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
                if( Game.ME!=null )
                    Game.ME.destroy();
                new Game();
            	if( Game.ME!=null )
                    Game.ME.onCdbReload();
            }, 0.33);
        });
		#end

		// Assets & data init
		Lang.init("en");
		Assets.init();
		Data.load( hxd.Res.data.entry.getText() );

		// Console
		new Console(Assets.font, s);

		// Game controller
		controller = new mt.heaps.Controller(s);
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.DOWN, Key.S, Key.ESCAPE);
		controller.bind(SELECT, Key.R);

		// Start
        new Game();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_HEIGHT>0 ) {
			Const.SCALE = MLib.floor( h()/Const.AUTO_SCALE_TARGET_HEIGHT );
			root.setScale(Const.SCALE);
		}
	}

    override function update() {
        super.update();
    }
}