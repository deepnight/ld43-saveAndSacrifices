class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;
		hxd.Timer.wantedFPS = Const.FPS;
		new Main(s2d);
		mt.Process.resizeAll();
	}

	override function onResize() {
		super.onResize();
		mt.Process.resizeAll();
	}

	var speed = 1.0;
	override function update(dt:Float) {
		super.update(dt);
		if( hxd.Key.isPressed(hxd.Key.NUMPAD_SUB) )
			speed = speed>=1 ? 0.33 : 1;
		var tmod = hxd.Timer.tmod * speed;
		mt.heaps.Controller.beforeUpdate();
		mt.Process.updateAll(tmod);
	}
}

