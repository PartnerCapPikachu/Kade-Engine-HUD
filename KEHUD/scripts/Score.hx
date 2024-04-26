import tjson.TJSON.parse;
import openfl.Lib.application;
import backend.CoolUtil;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

final scoreSettings = parse(File.getContent(Paths.mods('KEHUD/modSettings/Score.json')));

function trueTextScale(?number:Null<Float>):Int {
  number ??= 12;
  final remain:Float = number % 12;
  if (remain != 0) {
    number += 12 - remain;
  }
  final bounds:Rectangle = application.window.display.bounds;
  return Math.ceil(number * Math.min(FlxG.width / bounds.width, FlxG.height / bounds.height));
}

function calcMs(?getHitTime:Bool):Float {
  if (game.cpuControlled) {
    return 0;
  }
  var sum:Float = 0;
  for (noteHitTime in scoreSettings._ms._timings) {
    sum += Math.abs(noteHitTime);
  }
  final average:Float = sum / scoreSettings._ms._timings.length;
  getHitTime ??= false;
  return CoolUtil.floorDecimal(getHitTime ? average : Math.max(0, Math.min(100, (1 - (average * 0.00602409639)) * 100)), getHitTime ? 3 : 2);
}

scoreSettings._ratings._base = PlayState.ratingStuff;
if (scoreSettings._ratings._use && scoreSettings._ratings._kade.length != 0) {
  PlayState.ratingStuff = scoreSettings._ratings._kade;
}

final lmao:Array<String> = ['0xff00ffff', '0xff008000', '0xffff0000'];
scoreSettings._ms._msCounterColors ??= lmao;
for (i in 0...lmao.length) {
  scoreSettings._ms._msCounterColors[i] ??= lmao[i];
}

final msCounter:FlxText = new FlxText(0, 0, 0, '-000.000ms', trueTextScale(36));
final newScoreTxt:FlxText = new FlxText(0, 0, 0, 'hi', 16);

var zoomies:Bool = null;

function onCreatePost():Void {

  msCounter.alpha = 0.0001;
  msCounter.cameras = [game.camHUD];
  msCounter.setFormat(Paths.font('font.ttf'), trueTextScale(36), 0xffffffff, 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
  msCounter.borderSize = Math.ceil(Math.max(1, msCounter.size * 0.0833333333));
  msCounter.fieldWidth = msCounter.fieldWidth;
  msCounter.antialiasing = false;
  msCounter.visible = !ClientPrefs.data.hideHud;
  add(msCounter);

  newScoreTxt.cameras = [game.camHUD];
  newScoreTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, scoreSettings._score._stickToX ? 'left' : 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
  newScoreTxt.borderSize = 1;
  newScoreTxt.antialiasing = ClientPrefs.data.antialiasing;
  onUpdateScore();
  newScoreTxt.x = FlxG.width * 0.5 - newScoreTxt.width * 0.5;
  newScoreTxt.y = game.healthBar.bg.y + game.healthBar.bg.height * 2;
  newScoreTxt.visible = !ClientPrefs.data.hideHud;
  add(newScoreTxt);

  zoomies = ClientPrefs.data.scoreZoom;
  ClientPrefs.data.scoreZoom = game.scoreTxt.visible = false;

  return;

}

function onUpdatePost(elapsed:Float):Void {
  if (scoreSettings._nps._nps != 0) {
    for (time in scoreSettings._nps._npsArray) {
      if (time < Conductor.songPosition) {
        scoreSettings._nps._npsArray.remove(time);
        scoreSettings._nps._nps = scoreSettings._nps._npsArray.length;
        onUpdateScore();
      }
    }
  }
  return;
}

var curTween:FlxTween = null;

function goodNoteHit(daNote:Note):Void {

  if (daNote.isSustainNote) {
    return;
  }

  if (curTween != null && !curTween.finished) {
    curTween.cancel();
  }

  if (!game.cpuControlled) {

    scoreSettings._nps._npsArray[scoreSettings._nps._npsArray.length] = daNote.strumTime + 1000;
    scoreSettings._nps._nps = scoreSettings._nps._npsArray.length;
    if (scoreSettings._nps._max < scoreSettings._nps._nps) {
      scoreSettings._nps._max = scoreSettings._nps._nps;
    }

    scoreSettings._ms._timings.push(scoreSettings._ms._ms = CoolUtil.floorDecimal(daNote.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset, 3));

  }

  scoreSettings._ms._average = calcMs(true);
  scoreSettings._ms._accuracy = calcMs();

  msCounter.text = scoreSettings._ms._ms + 'ms';

  for (i in 0...2) {
    var res:Float = (i == 0 ? FlxG.width : FlxG.height) * 0.35 + 100;
    var offset:Float = ClientPrefs.data.comboOffset[i];
    offset -= i == 1 ? offset * 2 : 0;
    res += offset;
    if (i == 0) {
      msCounter.x = res;
    } else {
      msCounter.y = res;
    }
  }

  if (scoreSettings._ms._useColors) {
    msCounter.color = CoolUtil.colorFromString(scoreSettings._ms._msCounterColors[daNote.rating == 'sick' ? 0 : daNote.rating == 'good' ? 1 : 2]);
  }

  msCounter.alpha = 1;
  curTween = FlxTween.tween(msCounter, {alpha: 0.0001}, 0.2 / game.playbackRate, {startDelay: Conductor.crochet * 0.0015 / playbackRate});

  onUpdateScore();

  return;
}

// long ahh line
// just wanted to put it in a func
function getFC(_show:Object<Dynamic>):String {
  return (_show._rank ? '(' : '') + (game.cpuControlled ? 'Botplay' : game.ratingFC == '' ? 'N/A' : game.ratingFC == 'SFC' ? 'MFC' : game.ratingFC) + (_show._rank ? ')' : '');
}

function onUpdateScore(?miss:Bool):Void {

  final _show:Object<Dynamic> = scoreSettings._score._show;

  final scoreStr:Array<Dynamic> = [
    ['NPS: ' + scoreSettings._nps._nps + ' (' + scoreSettings._nps._max + ')', _show._nps, ' | '],
    ['Score: ' + game.songScore, _show._score, ' | '],
    ['Combo Breaks: ' + game.songMisses, _show._misses, ' | '],
    ['Average: ' + scoreSettings._ms._average + 'ms (' + scoreSettings._ms._accuracy + '%)', _show._ms, ' | '],
    ['Accuracy: ' + CoolUtil.floorDecimal(game.ratingPercent * 100, 2) + '%', _show._accuracy, ' | '],
    [game.ratingName, _show._rank, ' | '],
    [getFC(_show), _show._fc, _show._rank ? ' ' : ' | ']
  ];

  var finalTxt:String = '';

  for (txt in scoreStr) {
    if (txt[1]) {
      finalTxt += (finalTxt != '' ? txt[2] : '') + txt[0];
    }
  }

  game.scoreTxt.text = newScoreTxt.text = finalTxt;
  if (!scoreSettings._score._stickToX) {
    newScoreTxt.x = FlxG.width * 0.5 - newScoreTxt.width * 0.5;
  }

  return;

}

function onDestroy():Void {
  PlayState.ratingStuff = scoreSettings._ratings._base;
  ClientPrefs.data.scoreZoom = zoomies;
  return;
}