import mt.heaps.slib.*;
import mt.deepnight.Sfx;

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
		Sfx.setGroupVolume(0, 1);
		Sfx.setGroupVolume(1, 0.5);
		#if debug
		// Sfx.toggleMuteGroup(1);
		#end

		gameElements = mt.heaps.slib.assets.Atlas.load("gameElements.atlas");
		gameElements.defineAnim("peonRun", "0(4),1(10),0(4),2(7)");
		gameElements.defineAnim("peonStunRise", "0(7),1(7)");
	}
}