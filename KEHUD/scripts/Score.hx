import psychlua.LuaUtils.getModSetting;
import openfl.Lib.application;
import backend.CoolUtil;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

function trueTextScale(?number:Null<Float>):Int {
  number ??= 12;
  final remain:Float = number % 12;
  if (remain != 0) {
    number += 12 - remain;
  }
  final bounds:Rectangle = application.window.display.bounds;
  return Math.ceil(number * Math.min(FlxG.width / bounds.width, FlxG.height / bounds.height));
}

final baseRatings:Array<Dynamic> = PlayState.ratingStuff;
PlayState.ratingStuff = [
  ['F', 0], ['D', 0.5], ['C', 0.6], ['B', 0.7],
  ['A', 0.8], ['A.', 0.833333333], ['A:', 0.866666667],
  ['AA', 0.9], ['AA.', 0.91], ['AA:', 0.92],
  ['AAA', 0.93], ['AAA.', 0.94], ['AAA:', 0.95],
  ['AAAA', 0.96], ['AAAA.', 0.97], ['AAAA:', 0.98],
  ['AAAAA', 0.99], ['AAAAA:', 1], ['S', 1]
];

final msCounter:FlxText = new FlxText(0, 0, 0, '-000.000ms', trueTextScale(36));
msCounter.alpha = .0001;
msCounter.setFormat(Paths.font('font.ttf'), trueTextScale(36), 0xffffffff, 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
msCounter.borderSize = msCounter.size / 12; // i need the 0. or it's gonna die
msCounter.fieldWidth = msCounter.fieldWidth;
msCounter.antialiasing = false;
msCounter.visible = !ClientPrefs.data.hideHud;

final newScoreTxt:FlxText = new FlxText(0, 0, 0, 'hi', 16);
newScoreTxt.setFormat(Paths.font('vcr.ttf'), 16, 0xffffffff, getModSetting('KadeScoreStuckToStartingPosition', 'KEHUD') ? 'left' : 'center', FlxTextBorderStyle.OUTLINE, 0xff000000);
newScoreTxt.borderSize = 1;
newScoreTxt.antialiasing = ClientPrefs.data.antialiasing;
newScoreTxt.visible = !ClientPrefs.data.hideHud;

function onCreatePost():Void {
  msCounter.cameras = newScoreTxt.cameras = [game.camHUD];
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
  if (daNote.isSustainNote) {
    return;
  }
  if (!game.cpuControlled) {
    npsArray[npsArray.length] = daNote.strumTime + 1000;
    nps = npsArray.length;
    if (maxNps < nps) {
      maxNps = nps;
    }
    msTimings.push(ms = daNote.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
    var sum:Float = 0;
    for (noteHitTime in msTimings) {
      sum += Math.abs(noteHitTime);
    }
    msAccuracy = Math.min(1, Math.max(0, 1 - ((msAverage = sum / msTimings.length) / 166)));
  }
  msCounter.text = CoolUtil.floorDecimal(ms, 3) + 'ms';
  msCounter.setPosition(FlxG.width * .35 + 100 + ClientPrefs.data.comboOffset[0], FlxG.height * .35 + 100 - ClientPrefs.data.comboOffset[1]);
  msCounter.color = CoolUtil.colorFromString(msCounterColors[daNote.rating == 'sick' ? 0 : daNote.rating == 'good' ? 1 : 2]);
  msCounter.alpha = 1;
  curTween.cancel();
  curTween = FlxTween.tween(msCounter, {alpha: .0001}, .2 / game.playbackRate, {startDelay: Conductor.crochet * .0015 / playbackRate});
  onUpdateScore();
  return;
}

// long ahh line
// just wanted to put it in a func
function getFC(showFc:Bool):String {
  return (showFc ? '(' : '') + (game.cpuControlled ? 'Botplay' : game.ratingFC == '' ? 'N/A' : game.ratingFC == 'SFC' ? 'MFC' : game.ratingFC) + (showFc ? ')' : '');
}

final show:Array<Bool> = [
  getModSetting('KadeShowNpsInScoreTxt', 'KEHUD'),
  getModSetting('KadeShowScoreInScoreTxt', 'KEHUD'),
  getModSetting('KadeShowMissesInScoreTxt', 'KEHUD'),
  getModSetting('KadeShowMsInScoreTxt', 'KEHUD'),
  getModSetting('KadeShowAccuracyInScoreTxt', 'KEHUD'),
  getModSetting('KadeShowRankInScoreTxt', 'KEHUD'),
  getModSetting('KadeShowFcInScoreTxt', 'KEHUD'),
  !getModSetting('KadeScoreStuckToStartingPosition', 'KEHUD')
];

function onUpdateScore(?miss:Bool):Void {
  final scoreStuff:Array<Dynamic> = [
    ['NPS: ' + nps + ' (' + maxNps + ')', show[0], ' | '],
    ['Score: ' + game.songScore, show[1], ' | '],
    ['Combo Breaks: ' + game.songMisses, show[2], ' | '],
    ['Average: ' + CoolUtil.floorDecimal(msAverage, 3) + 'ms', show[3], ' | '],
    ['Accuracy: ' + CoolUtil.floorDecimal((game.ratingPercent + msAccuracy) * 50, 2) + '%', show[4], ' | '],
    [game.ratingName, show[5], ' | '],
    [getFC(show[5]), show[6], show[5] ? ' ' : ' | ']
  ];
  var finalTxt:String = '';
  for (txt in scoreStuff) {
    if (txt[1]) {
      finalTxt += (finalTxt != '' ? txt[2] : '') + txt[0];
    }
  }
  game.scoreTxt.text = newScoreTxt.text = finalTxt;
  if (show[7]) {
    newScoreTxt.x = FlxG.width * .5 - newScoreTxt.width * .5;
  }
  return;
}

function onDestroy():Void {
  PlayState.ratingStuff = baseRatings;
  return;
}