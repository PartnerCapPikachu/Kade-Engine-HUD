import states.MainMenuState.psychEngineVersion;
import lime.app.Application.current;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

// show - If false, script breaks off and doesn't even create the watermark.
// trick - If true, copies Kade stuff.
// versionToTrick - If trick and this is true, uses the inputted text as the version.
// simpleText - If true, the watermark becomes more simple.
// stickToLeft - If true, watermark doesn't center.
var watermarkSettings:Object<Dynamic> = {
  show: true,
  trick: false,
  versionToTrick: '1.8',
  simpleText: false,
  stickToLeft: true
};

if (!watermarkSettings.show) {return;}

final engine:Array<String> = [['KE', 'Kade Engine'], ['PE', 'Psych Engine']];
final version:String = watermarkSettings.trick ? (Std.string(watermarkSettings.versionToTrick) ?? '1.8') : 'v' + psychEngineVersion;
var name:String = PlayState.SONG.song + ' (' + game.storyDifficultyText + ') | ' + (
engine[watermarkSettings.trick ? 0 : 1][watermarkSettings.simpleText ? 0 : 1] + ' ' + version + (
watermarkSettings.simpleText ? '' : ' | Friday Night Funkin\' v' + current.meta.get('version')));

// onCreatePost doesn't work?????????????
function onCountdownStarted() {
  var watermarkTxt:FlxText = new FlxText(0, 0, 0, name, 16);
  watermarkTxt.cameras = [game.camHUD];
  watermarkTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
  watermarkTxt.borderSize = 1;
  if (!watermarkSettings.stickToLeft) {watermarkTxt.x = FlxG.width / 2 - watermarkTxt.width / 2;}
  watermarkTxt.y = FlxG.height - watermarkTxt.height;
  watermarkTxt.antialiasing = ClientPrefs.data.antialiasing;
  add(watermarkTxt);
  return;
}