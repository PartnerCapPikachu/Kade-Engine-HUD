import openfl.Lib.application as app;
import backend.CoolUtil;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle.OUTLINE;

final options:Object<Bool,Object<Bool>> = {
  stickScoreLeft: !getModSetting('KadeScoreStuckToStartingPosition', 'KEHUD'),
  show: {
    nps: getModSetting('KadeShowNpsInScoreTxt', 'KEHUD'),
    score: getModSetting('KadeShowScoreInScoreTxt', 'KEHUD'),
    misses: getModSetting('KadeShowMissesInScoreTxt', 'KEHUD'),
    ms: getModSetting('KadeShowMsInScoreTxt', 'KEHUD'),
    accuracy: getModSetting('KadeShowAccuracyInScoreTxt', 'KEHUD'),
    rank: getModSetting('KadeShowRankInScoreTxt', 'KEHUD'),
    fc: getModSetting('KadeShowFcInScoreTxt', 'KEHUD')
  }
};

final baseRatings:Array<Dynamic> = PlayState.ratingStuff;
PlayState.ratingStuff = [
  ['D', .5], ['C', .6], ['B', .7],
  ['A', .8], ['A.', .85], ['A:', .90],
  ['AA', .93], ['AA.', .965], ['AA:', .99],
  ['AAA', .997], ['AAA.', .998], ['AAA:', .999],
  ['AAAA', .99955], ['AAAA.', .9997], ['AAAA:', .9998],
  ['AAAAA', 1], ['S', 1]
];

final msCounter:FlxText = new FlxText(0, 0, 0, '-000.000ms', 36 * FlxG.width / app.window.display.bounds.width);
msCounter.alpha = .0001;
msCounter.setFormat(Paths.font('font.ttf'), msCounter.size, 0xffffffff, 'center', OUTLINE, 0xff000000);
msCounter.borderSize = msCounter.size / 12;
msCounter.fieldWidth = msCounter.fieldWidth;
msCounter.antialiasing = false;

final newScoreTxt:FlxText = new FlxText(0, 0, 0, 'hi', 16);
newScoreTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, options.stickScoreLeft ? 'left' : 'center', OUTLINE, 0xff000000);
newScoreTxt.borderSize = 1;
newScoreTxt.antialiasing = ClientPrefs.data.antialiasing;

msCounter.visible = newScoreTxt.visible = !ClientPrefs.data.hideHud;
msCounter.cameras = newScoreTxt.cameras = [game.camHUD];

function onCreatePost():Void {
  newScoreTxt.setPosition(FlxG.width * .5 - newScoreTxt.width * .5, game.healthBar.bg.y + game.healthBar.bg.height * 2);
  add(msCounter);
  add(newScoreTxt);
  game.scoreTxt.visible = false;
  return;
}

var nps:Int = 0;
var npsArray:Array<Float> = [];
var maxNps:Int = 0;

var ms:Float = 0;
var msTimings:Array<Float> = [];
var msAverage:Float = 0;
var msAccuracy:Float = 0;
final msCounterColors:Array<String> = ['0xff00ffff', '0xff008000', '0xffff0000'];

function onUpdate(elapsed:Float):Void {
  if (nps != 0) {
    for (time in npsArray) {
      if (time < Conductor.songPosition) {
        npsArray.remove(time);
        nps = npsArray.length;
        onUpdateScore();
      }
    }
  }
  return;
}

var curTween:FlxTween = FlxTween.tween(msCounter, {alpha: .0001});

function goodNoteHit(daNote:Note):Void {

  if (!daNote.isSustainNote) {

    if (!game.cpuControlled) {
      npsArray[npsArray.length] = daNote.strumTime + 1000;
      nps = npsArray.length;
      if (maxNps < nps) {
        maxNps = nps;
      }
      msTimings.push(ms = daNote.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
      onUpdateScore();
    }
  
    msCounter.text = CoolUtil.floorDecimal(ms, 3) + 'ms';
    msCounter.setPosition(FlxG.width * .35 + 100 + ClientPrefs.data.comboOffset[0], FlxG.height * .35 + 100 - ClientPrefs.data.comboOffset[1]);
    msCounter.color = CoolUtil.colorFromString(msCounterColors[daNote.rating == 'sick' ? 0 : daNote.rating == 'good' ? 1 : 2]);
    msCounter.alpha = 1;
    curTween.cancel();
    curTween = FlxTween.tween(msCounter, {alpha: .0001}, .2 / game.playbackRate, {startDelay: Conductor.crochet * .0015 / playbackRate});

  }

  return;

}

function onUpdateScore(?miss:Bool):Void {

  if (game.songHits != 0 && game.totalPlayed != 0) {
    var sum:Float = 0;
    for (noteHitTime in msTimings) {
      sum += Math.abs(noteHitTime);
    }
    msAccuracy = Math.min(1, Math.max(0, ((game.totalNotesHit / game.totalPlayed) + (1 - ((msAverage = sum / msTimings.length) / 166))) * .5));
  }

  final scoreStuff:Array<Dynamic> = [
    ['NPS: ' + nps + ' (' + maxNps + ')',
      options.show.nps, ' | '],
    ['Score: ' + game.songScore,
      options.show.score, ' | '],
    ['Combo Breaks: ' + game.songMisses,
      options.show.misses, ' | '],
    ['Average: ' + CoolUtil.floorDecimal(msAverage, 3) + 'ms',
      options.show.ms, ' | '],
    ['Accuracy: ' + CoolUtil.floorDecimal(msAccuracy * 100, 2) + '%',
      options.show.accuracy, ' | '],
    [game.ratingName,
      options.show.rank, ' | '],
    [(options.show.rank ? '(' : '') + (game.cpuControlled ? 'Botplay' : game.ratingFC == '' ? 'N/A' : game.ratingFC == 'SFC' ? 'MFC' : game.ratingFC) + (options.show.rank ? ')' : ''),
      options.show.fc, options.show.rank ? ' ' : ' | ']
  ];

  var finalTxt:String = '';
  for (txt in scoreStuff) {
    if (txt[1]) {
      finalTxt += (finalTxt != '' ? txt[2] : '') + txt[0];
    }
  }

  game.scoreTxt.text = newScoreTxt.text = finalTxt;
  if (options.stickScoreLeft) {
    newScoreTxt.x = FlxG.width * .5 - newScoreTxt.width * .5;
  }

  return;

}

function onDestroy():Void {
  PlayState.ratingStuff = baseRatings;
  return;
}