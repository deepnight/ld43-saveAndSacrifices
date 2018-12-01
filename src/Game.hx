import mt.Process;
import mt.MLib;
import mt.deepnight.CdbHelper;

class Game extends mt.Process {
	var ca : mt.heaps.Controller.ControllerAccess;

	public static var ME : Game;
	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		createRootInLayers(Main.ME.root, Const.DP_BG);
	}

	public function onCdbReload() {
	}

	override function update() {
		super.update();
	}
}

