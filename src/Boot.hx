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
		dn.Process.resizeAll();
	}

	override function onResize() {
		super.onResize();
		dn.Process.resizeAll();
	}

	var speed = 1.0;
	override function update(dt:Float) {
		super.update(dt);

		// Bullet time
		#if debug
		if( hxd.Key.isPressed(hxd.Key.NUMPAD_SUB) )
			speed = speed>=1 ? 0.33 : 1;
		#end

		var tmod = hxd.Timer.tmod * speed;
		#if debug
		tmod *= hxd.Key.isDown(hxd.Key.NUMPAD_ADD) || Main.ME!=null && Main.ME.ca.ltDown() ? 5 : 1;
		#end
		dn.heaps.Controller.beforeUpdate();
		dn.Process.updateAll(tmod);
	}
}

