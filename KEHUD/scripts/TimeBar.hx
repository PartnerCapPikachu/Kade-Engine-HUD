import openfl.Lib.application;
import flixel.group.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

if (ClientPrefs.data.timeBarType == 'Disabled' || ClientPrefs.data.hideHud) {
  return game.hscriptArray.remove(game.hscriptArray[game.hscriptArray.indexOf(this)]);
}

final barGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
barGroup.alpha = 0.0001;
barGroup.cameras = [game.camHUD];
add(barGroup);

final bg:FlxSprite = new FlxSprite().makeGraphic(605, 25, 0xff000000); // edit bulk here
bg.x = FlxG.width * 0.5 - bg.width * 0.5;
bg.y = ClientPrefs.data.downScroll ? (FlxG.height - bg.height) - 10 : 10;
barGroup.add(bg);

final bg2:FlxSprite = new FlxSprite().makeGraphic(bg.width - 10, bg.height - 10, 0xff808080);
bg2.x = bg.x + 5;
bg2.y = bg.y + 5;
barGroup.add(bg2);

final time:FlxSprite = new FlxSprite().makeGraphic(1, bg2.height, 0xff00ff00);
time.x = bg2.x;
time.y = bg2.y;
barGroup.add(time);

final barTxt:FlxText = new FlxText(0, 0, 0, ClientPrefs.data.timeBarType == 'Song Name' ? PlayState.SONG.song : '00:00', 16);
barTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
barTxt.size = bg2.height + 5;
barTxt.borderSize = 1;
barTxt.fieldWidth = barTxt.fieldWidth;
barTxt.x = bg.x + bg.width * 0.5 - barTxt.width * 0.5;
barTxt.y = bg2.y - bg2.height * 0.25;
barTxt.antialiasing = ClientPrefs.data.antialiasing;
barGroup.add(barTxt);

function onCreatePost():Void {
  game.timeBar.visible = game.timeTxt.visible = false;
  return;
}

function onSongStart():Void {
  FlxTween.tween(barGroup, {alpha: 1}, 0.4 + 0.004 * game.stepCrochet / game.playbackRate);
  return;
}

function onUpdatePost(elapsed:Float):Void {
  time._frame.frame.width = game.songPercent * bg2.width;
  if (barTxt != null && barTxt.text != game.timeTxt.text) {
    barTxt.text = game.timeTxt.text; // no need to change it every frame when it's the same usually
  }
  return;
}