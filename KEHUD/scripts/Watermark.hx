import psychlua.LuaUtils.getModSetting;
import states.MainMenuState.psychEngineVersion;
import lime.app.Application.current;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle.OUTLINE;

if (!getModSetting('KadeShowWatermark', 'KEHUD') || ClientPrefs.data.hideHud) {
  return;
}

final songAndDiff:String = PlayState.SONG.song + ' (' + game.storyDifficultyText + ') | ';
final engineName:String = ['PE', 'Psych Engine'][getModSetting('KadeSimpleWatermark', 'KEHUD') ? 0 : 1] + ' ';
final leVersion:String = 'v' + psychEngineVersion;
final funkinVersion:String = getModSetting('KadeSimpleWatermark', 'KEHUD') ? '' : ' | Friday Night Funkin\' v' + current.meta.get('version');

final watermarkTxt:FlxText = new FlxText(0, 0, 0, songAndDiff + engineName + leVersion + funkinVersion, 16);
watermarkTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'center', OUTLINE, 0xff000000);
watermarkTxt.borderSize = 1;
watermarkTxt.cameras = [game.camHUD];
watermarkTxt.antialiasing = ClientPrefs.data.antialiasing;

function onCreatePost():Void {
  watermarkTxt.setPosition(!getModSetting('KadeStickWatermarkToLeft', 'KEHUD') ? FlxG.width * .5 - watermarkTxt.width * .5 : 0, game.healthBar.bg.y + game.healthBar.bg.height * 3);
  add(watermarkTxt);
  return;
}