import tjson.TJSON.parse;
import states.MainMenuState.psychEngineVersion;
import lime.app.Application.current;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

final watermarkSettings = parse(File.getContent(Paths.mods('KEHUD/modSettings/Watermark.json')));

final songAndDiff:String = PlayState.SONG.song + ' (' + game.storyDifficultyText + ') | ';
final engineName:String = [['KE', 'Kade Engine'], ['PE', 'Psych Engine']][watermarkSettings.trick ? 0 : 1][watermarkSettings.simpleText ? 0 : 1] + ' ';
final leVersion:String = watermarkSettings.trick ? (Std.string(watermarkSettings.versionToTrick) ?? '1.8') : 'v' + psychEngineVersion;
final funkinVersion:String = watermarkSettings.simpleText ? '' : ' | Friday Night Funkin\' v' + current.meta.get('version');

function onCountdownStarted():Void {
  final watermarkTxt:FlxText = new FlxText(0, 0, 0, songAndDiff + engineName + leVersion + funkinVersion, 16);
  watermarkTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
  watermarkTxt.borderSize = 1;
  watermarkTxt.cameras = [game.camHUD];
  if (!watermarkSettings.stickToLeft) {
    watermarkTxt.x = FlxG.width * 0.5 - watermarkTxt.width * 0.5;
  }
  watermarkTxt.y = game.healthBar.bg.y + game.healthBar.bg.height * 3; // FlxG.height - watermarkTxt.height;
  watermarkTxt.antialiasing = ClientPrefs.data.antialiasing;
  add(watermarkTxt);
  return;
}