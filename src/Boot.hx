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

	override function update(dt:Float) {
		super.update(dt);
		var tmod = hxd.Timer.tmod;
		mt.heaps.Controller.beforeUpdate();
		mt.Process.updateAll(tmod);
	}
}

