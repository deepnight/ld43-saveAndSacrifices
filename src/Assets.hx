import dn.heaps.slib.*;
// import dn.Sfx;

class Assets {
	// public static var SFX = Sfx.importDirectory("sfx");
	// public static var MUS = Sfx.importDirectory("music");
	public static var gameElements : SpriteLib;
	public static var levelTiles : h2d.Tile;
	public static var font : h2d.Font;

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		font = hxd.Res.minecraftiaOutline.toFont();
		levelTiles = hxd.Res.levelTiles.toTile();

		// Sound init
		// Sfx.setGroupVolume(0, 1);
		// Sfx.setGroupVolume(1, 0.5);
		// #if debug
		// Sfx.toggleMuteGroup(1);
		// #end

		gameElements = dn.heaps.assets.Atlas.load("gameElements.atlas");
		gameElements.defineAnim("peonTaken", "0-1(6)");
		gameElements.defineAnim("peonRun", "0(4),1(10),0(4),2(7)");
		gameElements.defineAnim("peonStunRise", "0(7),1(7)");

		gameElements.defineAnim("workerTaken", "0-1(6)");
		gameElements.defineAnim("workerRun", "0(4),1(10),0(4),2(7)");
		gameElements.defineAnim("workerStunRise", "0(7),1(7)");

		gameElements.defineAnim("heroIdle", "0-3(16)");
		gameElements.defineAnim("heroKick", "0(2),1(8),2(4)");
		gameElements.defineAnim("heroRun", "0(4),1(8),2(4),3(8)");
		gameElements.defineAnim("wingsFlap", "0(6),1(5),2(4),3(3),4(3)");
		gameElements.defineAnim("demonWings", "0(8),1(3),2(4),3(5),4(3)");
		gameElements.defineAnim("bomberTrigger", "0-2(4)");

		gameElements.defineAnim("lightOn", "0(4),1(4),2(3)");
	}
}