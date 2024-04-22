// "A_" in file name to load this file first. Should also call onCountdownStarted first when the song is loaded.
// Time prints in milliseconds.

import haxe.Timer.stamp;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import backend.CoolUtil.floorDecimal;

final start:Float = stamp();

final printTime:Bool = true;
if (!printTime) {
  return game.hscriptArray.remove(game.hscriptArray[game.hscriptArray.indexOf(this)]);
}

var timeLoadedTxt:FlxText = new FlxText(FlxG.width, 0, 0, start, 16);
timeLoadedTxt.alpha = 0.0001;
timeLoadedTxt.cameras = [game.camOther];
timeLoadedTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, 'right', FlxTextBorderStyle.OUTLINE, 0xff000000);
timeLoadedTxt.antialiasing = ClientPrefs.data.antialiasing;
add(timeLoadedTxt);

var justLoaded:Bool = false;

function onUpdate(elapsed:Float):Void {

  if (justLoaded) {
    return;
  }
  justLoaded = true;

  timeLoadedTxt.text = 'Start of load -> text update:\n' + floorDecimal(stamp() - start, 3) + ' seconds';
  timeLoadedTxt.fieldWidth = timeLoadedTxt.fieldWidth;
  timeLoadedTxt.x -= timeLoadedTxt.width;
  timeLoadedTxt.alpha = 1;
  FlxTween.tween(timeLoadedTxt, {alpha: 0}, 0.4 + (game.stepCrochet * 0.004) / game.playbackRate, {startDelay: 1 + Conductor.crochet * 0.0015 / playbackRate,
    onComplete: function(t:FlxTween):Dynamic {
      timeLoadedTxt.active = false;
      timeLoadedTxt.kill();
      remove(timeLoadedTxt);
      timeLoadedTxt.destroy();
      timeLoadedTxt = null;
      return game.hscriptArray.remove(game.hscriptArray[game.hscriptArray.indexOf(this)]);
    }
  });

  return;

}