import states.MainMenuState.psychEngineVersion;
import lime.app.Application.current as curApp;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle.OUTLINE;

final options:Object<Bool> = {
  enabled: getModSetting('KadeShowWatermark', 'KEHUD') && !ClientPrefs.data.hideHud,
  simple: getModSetting('KadeSimpleWatermark', 'KEHUD'),
  stickLeft: !getModSetting('KadeStickWatermarkToLeft', 'KEHUD')
};

final songAndDiff:String = PlayState.SONG.song + ' (' + game.storyDifficultyText + ') | ';
final engineName:String = ['PE', 'Psych Engine'][options.simple ? 0 : 1] + ' ';
final leVersion:String = 'v' + psychEngineVersion;
final funkinVersion:String = options.simple ? '' : ' | Friday Night Funkin\' v' + curApp.meta.get('version');

final watermarkTxt:FlxText = new FlxText(0, 0, 0, songAndDiff + engineName + leVersion + funkinVersion, 16);
watermarkTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'center', OUTLINE, 0xff000000);
watermarkTxt.borderSize = 1;
watermarkTxt.cameras = [game.camHUD];
watermarkTxt.antialiasing = ClientPrefs.data.antialiasing;
watermarkTxt.visible = options.enabled;

function onCreatePost():Void {
  watermarkTxt.setPosition(options.stickLeft ? FlxG.width * .5 - watermarkTxt.width * .5 : 0, game.healthBar.bg.y + game.healthBar.bg.height * 3);
  add(watermarkTxt);
  return;
}