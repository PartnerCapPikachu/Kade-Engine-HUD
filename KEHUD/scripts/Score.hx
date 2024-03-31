import openfl.Lib.application;
import backend.CoolUtil.floorDecimal;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

// stickToX - If true, score text will be centered on the start but won't center upon updating it.
// show.any - If it's false, it won't add that part to the text.
// useColors - If true, ms counter will be colored depending on your hit. You can also replace the color values with your own.
var scoreSettings:Object<Dynamic> = {
  _score: {
    _stickToX: false,
    _show: {
      _nps: true,
      _score: true,
      _misses: true,
      _ms: true,
      _accuracy: true,
      _rank: true,
      _fc: true
    }
  },
  _nps: {
    _nps: [],
    _max: 0
  },
  _ms: {
    _ms: 0,
    _timings: [],
    _average: 0,
    _accuracy: 0,
    _useColors: true,
    _msCounterColors: [0xff00ffff, 0xff008000, 0xffff0000], // cyan, green, red
    _alphaDuration: 0
  },
  _ratings: {
    _use: true,
    _kade: [
      ['F', 0], ['D', 0.5], ['C', 0.6], ['B', 0.7],
      ['A', 0.8], ['A.', 0.85], ['A:', 0.9],
      ['AA', 0.93], ['AA.', 0.9650], ['AA:', 0.99],
      ['AAA', 0.9970], ['AAA.', 0.9980], ['AAA:', 0.999],
      ['AAAA', 0.99955], ['AAAA.', 0.9997], ['AAAA:', 0.9998],
      ['AAAAA', 0.999935]
    ],
    _base: []
  }
};

function trueTextScale(?number:Null<Float>):Int {
  number ??= 12;
  final remain:Float = number % 12;
  if (remain != 0) {number += 12 - remain;}
  final bounds:Rectangle = application.window.display.bounds;
  return Math.ceil(number * Math.min(FlxG.width / bounds.width, FlxG.height / bounds.height));
}

function calcMs(?getHitTime:Bool):Float {
  if (game.cpuControlled) {return 0;}
  var sum:Float = 0;
  for (noteHitTime in scoreSettings._ms._timings) {sum += Math.abs(noteHitTime);}
  final average:Float = sum / scoreSettings._ms._timings.length;
  getHitTime ??= false;
  return floorDecimal(getHitTime ? average : Math.max(0, Math.min(100, (1 - (average / 166)) * 100)), getHitTime ? 3 : 2);
}

scoreSettings._ratings._base = PlayState.ratingStuff;
if (scoreSettings._ratings._use) {
  PlayState.ratingStuff = scoreSettings._ratings._kade;
}

var msCounter:FlxText = new FlxText(0, 0, 0, '-000.000ms', trueTextScale(36));
var newScoreTxt:FlxText = new FlxText(0, 0, 0, 'hi', 16);

function onCreatePost() {

  msCounter.alpha = 0.0001;
  msCounter.cameras = [game.camHUD];
  msCounter.setFormat(Paths.font('font.ttf'), trueTextScale(36), 0xffffffff, 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
  msCounter.borderSize = Math.ceil(Math.max(1, msCounter.size / 12));
  msCounter.fieldWidth = msCounter.fieldWidth;
  msCounter.antialiasing = false;
  msCounter.visible = !ClientPrefs.data.hideHud;
  add(msCounter);

  newScoreTxt.cameras = [game.camHUD];
  newScoreTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, scoreSettings._score._stickToX ? 'left' : 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
  newScoreTxt.borderSize = 1;
  newScoreTxt.antialiasing = ClientPrefs.data.antialiasing;
  onUpdateScore();
  newScoreTxt.x = FlxG.width / 2 - newScoreTxt.width / 2;
  newScoreTxt.y = game.healthBar.bg.y + game.healthBar.bg.height * 2;
  newScoreTxt.visible = !ClientPrefs.data.hideHud;
  add(newScoreTxt);

  game.scoreTxt.visible = false;

  return;

}

function onUpdatePost(elapsed:Float) {
  if (scoreSettings._nps._nps.length < 1) {return;}
  for (time in scoreSettings._nps._nps) {
    if (time >= Conductor.songPosition) {continue;}
    scoreSettings._nps._nps.remove(time);
    onUpdateScore();
  }
  return;
}

var curTween:FlxTween = null;

function goodNoteHit(daNote:Note) {

  if (daNote.isSustainNote) {return;}

  if (!game.cpuControlled) {
    scoreSettings._nps._nps[scoreSettings._nps._nps.length] = daNote.strumTime + 1000;
    if (scoreSettings._nps._max < scoreSettings._nps._nps.length) {scoreSettings._nps._max = scoreSettings._nps._nps.length;}
  }

  scoreSettings._ms._ms = game.cpuControlled ? 0 : floorDecimal(daNote.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset, 3);

  if (!game.cpuControlled) {
    scoreSettings._ms._timings.push(scoreSettings._ms._ms);
  }

  scoreSettings._ms._average = calcMs(true);
  scoreSettings._ms._accuracy = calcMs();

  msCounter.text = scoreSettings._ms._ms + 'ms';

  for (i in 0...2) {
    var res:Float = (i == 0 ? FlxG.width : FlxG.height) * 0.35 + 100;
    var offset:Float = ClientPrefs.data.comboOffset[i];
    offset -= i == 1 ? offset * 2 : 0;
    res += offset;
    if (i == 0) {msCounter.x = res;} else {msCounter.y = res;}
  }

  if (scoreSettings._ms._useColors) {
    msCounter.color = scoreSettings._ms._msCounterColors[daNote.rating == 'sick' ? 0 : daNote.rating == 'good' ? 1 : 2];
  }

  if (curTween != null && !curTween.finished) {curTween.cancel();}
  msCounter.alpha = 1;
  curTween = FlxTween.tween(msCounter, {alpha: 0.0001}, 0.2 / game.playbackRate, {startDelay: Conductor.crochet * 0.0015 / playbackRate});

  onUpdateScore();

  return;

}

function onUpdateScore(?miss:Bool) {

  final _show:Object<Dynamic> = scoreSettings._score._show;

  final checks:Array<Dynamic> = [
    ['NPS: ' + scoreSettings._nps._nps.length + ' (' + scoreSettings._nps._max + ')', _show._nps, ' | '],
    ['Score: ' + game.songScore, _show._score, ' | '],
    ['Combo Breaks: ' + game.songMisses, _show._misses, ' | '],
    ['Average: ' + scoreSettings._ms._average + 'ms (' + scoreSettings._ms._accuracy + '%)', _show._ms, ' | '],
    ['Accuracy: ' + floorDecimal(game.ratingPercent * 100, 2) + '%', _show._accuracy, ' | '],
    [game.ratingName, _show._rank, ' | '],
    [(_show._rank ? '(' : '') + (game.cpuControlled ? 'Botplay' : game.ratingFC == '' ? 'N/A' : game.ratingFC == 'SFC' ? 'MFC' : game.ratingFC) + (_show._rank ? ')' : ''),
    _show._fc, _show._rank ? ' ' : ' | ']
  ];

  var finalTxt:String = '';
  for (check in checks) {
    if (!check[1]) {continue;}
    if (finalTxt != '') {finalTxt += check[2];}
    finalTxt += check[0];
  }

  game.scoreTxt.text = newScoreTxt.text = finalTxt;
  if (!scoreSettings._score._stickToX) {newScoreTxt.x = FlxG.width / 2 - newScoreTxt.width / 2;}

  return;

}

function onDestroy() {
  PlayState.ratingStuff = scoreSettings._ratings._base;
  return;
}
