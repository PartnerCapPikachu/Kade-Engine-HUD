import openfl.Lib.application;
import flixel.group.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

// [0] is the width, and the other is height
// int recommended so the type is set to it
// defaults are [605, 25]
var timeBarBulk:Array<Int> = [605, 25];

var barGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
barGroup.alpha = 0.0001;
barGroup.cameras = [game.camHUD];
add(barGroup);

var bg:FlxSprite = new FlxSprite().makeGraphic(timeBarBulk[0] ?? 605, timeBarBulk[1] ?? 25, 0xff000000);
bg.x = FlxG.width / 2 - bg.width / 2;
bg.y = ClientPrefs.data.downScroll ? (FlxG.height - bg.height) - 10 : 10;
barGroup.add(bg);

var bg2:FlxSprite = new FlxSprite().makeGraphic(bg.width - 10, bg.height - 10, 0xff808080);
bg2.x = bg.x + 5;
bg2.y = bg.y + 5;
barGroup.add(bg2);

var time:FlxSprite = new FlxSprite().makeGraphic(1, bg2.height, 0xff00ff00);
time.x = bg2.x;
time.y = bg2.y;
barGroup.add(time);

var barTxt:FlxText = new FlxText(0, 0, FlxG.width, '', 16);
barTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
barTxt.size = bg2.height + 5;
barTxt.borderSize = 1;
barTxt.y = bg2.y - bg2.height / 4;
barTxt.antialiasing = ClientPrefs.data.antialiasing;
barGroup.add(barTxt);

function onCreatePost() {
  game.timeBar.visible = game.timeTxt.visible = false;
  return;
}

function onSongStart() {
  FlxTween.tween(barGroup, {alpha: 1}, (0.4 + (0.004 * game.stepCrochet)) / game.playbackRate);
  return;
}

function onUpdatePost(elapsed:Float) {
  if (barTxt.text != game.timeTxt.text) {barTxt.text = game.timeTxt.text;}
  time._frame.frame.width = songPercent * bg2.width;
  return;
}