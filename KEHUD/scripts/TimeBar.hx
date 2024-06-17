import flixel.group.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle.OUTLINE;

final barGroup:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();
barGroup.alpha = .0001;
barGroup.cameras = [game.camHUD];
barGroup.scrollFactor.set();
add(barGroup);

final bg:FlxSprite = new FlxSprite().makeGraphic(605, 25, 0xff000000); // edit bulk here
bg.setPosition(FlxG.width * .5 - bg.width * .5, ClientPrefs.data.downScroll ? FlxG.height - bg.height - 10 : 10);
barGroup.add(bg);

final bg2:FlxSprite = new FlxSprite().makeGraphic(bg.width - 10, bg.height - 10, 0xff808080);
bg2.setPosition(bg.x + 5, bg.y + 5);
barGroup.add(bg2);

final time:FlxSprite = new FlxSprite().makeGraphic(bg2.width, bg2.height, 0xff00ff00);
time.setPosition(bg2.x, bg2.y);
barGroup.add(time);

final barTxt:FlxText = new FlxText(0, 0, 0, ClientPrefs.data.timeBarType == 'Song Name' ? PlayState.SONG.song : '00:00', 16);
barTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'center', OUTLINE, 0xff000000);
barTxt.size = bg2.height + 5;
barTxt.borderSize = 1;
barTxt.fieldWidth = barTxt.fieldWidth;
barTxt.setPosition(bg.x + bg.width * .5 - barTxt.width * .5, bg2.y - bg2.height * .25);
barTxt.antialiasing = ClientPrefs.data.antialiasing;
barGroup.add(barTxt);

function onCreatePost():Void {
  barGroup.visible = game.timeBar.visible;
  game.timeBar.visible = game.timeTxt.visible = false;
  return;
}

function onSongStart():Void {
  FlxTween.tween(barGroup, {alpha: 1}, .4 + game.stepCrochet * .004 / game.playbackRate);
  return;
}

function onUpdatePost(elapsed:Float):Void {
  if (game.songPercent >= 0) {
    time._frame.frame.width = Math.min(game.songPercent * bg2.width, bg2.width);
  }
  if (barTxt.text != game.timeTxt.text) {
    barTxt.text = game.timeTxt.text; // no need to change it every frame when it's the same usually
  }
  return;
}