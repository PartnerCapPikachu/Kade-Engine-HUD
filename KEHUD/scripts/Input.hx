// not recommended to edit but meh

import psychlua.LuaUtils.Function_Stop as funcStop;

function addEvents(a, b):Void {
  for (c in [['Down', a], ['Up', b]]) {
    if (c[1] != null) {
      FlxG.stage.addEventListener('key' + c[0], c[1]);
    }
  }
  return;
}

function destroyEvents(a, b):Void {
  for (c in [['Down', a], ['Up', b]]) {
    if (c[1] != null) {
      FlxG.stage.removeEventListener('key' + c[0], c[1]);
    }
  }
  return;
}

function notNull(a:Any):Bool {
  return a != null && a.exists && a.active;
}

function getKey(tbl:Array<String>, code:Int):Int {
  var leKey:Int = -1;
  if (code != leKey) {
    for (i in 0...tbl.length) {
      if (ClientPrefs.keyBinds[tbl[i]].indexOf(code) != leKey) {
        leKey = i;
        break;
      }
    }
  }
  return leKey;
}

function input(event:openfl.events.KeyboardEvent):Dynamic {

  if (game.controls.controllerMode) {
    return;
  }

  final key:Int = getKey(game.keysArray, event.keyCode);
  if (key < 0 || key > game.playerStrums.length - 1) {
    return;
  }

  final called:String = game.controls.justPressed(game.keysArray[key]) ? 'Press' : game.controls.justReleased(game.keysArray[key]) ? 'Release' : '';
  if (called == '') {
    return;
  }

  return game.callOnScripts('input' + called, [key]);

}

function inputPress(key:Int):Dynamic {

  if (game.inCutscene || game.paused || game.endingSong || game.cpuControlled || !game.generatedMusic ||
  !game.startedCountdown || (notNull(game.boyfriend) && game.boyfriend.stunned) || game.strumsBlocked[key]) {
    return null;
  }

  if (game.callOnScripts('onKeyPressPre', [key]) == funcStop) {
    return null;
  }

  final lastTime:Float = Conductor.songPosition;
  if (!game.startingSong || lastTime >= 0) {
    Conductor.songPosition = FlxG.sound.music.time;
  }

  var sortedNotesList:Array<Note> = [];
  if (game.notes.members.length != 0) {
    sortedNotesList = game.notes.members.filter(function(a:Note):Bool {
      return notNull(a) && a.noteData == key && a.mustPress && a.canBeHit && !a.tooLate && !a.wasGoodHit &&
      !a.missed && !a.hitByOpponent && !a.noteWasHit && a.spawned && !a.blockHit && !a.isSustainNote;
    });
  }

  if (sortedNotesList.length != 0) {

    sortedNotesList.sort(function(a:Note, b:Note):Int {
      return a.lowPriority && !b.lowPriority ? -1 : !a.lowPriority && b.lowPriority ? 1 : Std.int(b.strumTime - a.strumTime);
    });

    final coolNote:Note = sortedNotesList[sortedNotesList.length - 1];

    if (sortedNotesList.length > 1) {
      for (epicNote in sortedNotesList) {
        if (notNull(epicNote) && notNull(coolNote) && epicNote != coolNote &&
        epicNote.strumTime - coolNote.strumTime <= 12.5 * 100 / Conductor.bpm) {
          game.invalidateNote(epicNote);
        }
      }
    }

    sortedNotesList = [];

    if (notNull(coolNote)) {
      game.goodNoteHit(coolNote);
    }

  } else {

    game.callOnScripts('onGhostTap', [key]);
    if (!ClientPrefs.data.ghostTapping) {
      game.noteMissPress(key);
    }

  }

  final strum:StrumNote = game.playerStrums.members[key];
  if (notNull(strum) && strum.animation.curAnim.name != 'confirm') {
    strum.playAnim('pressed');
    strum.resetAnim = 0;
  }

  if (!game.keysPressed.contains(key)) {
    game.keysPressed.push(key);
  }

  Conductor.songPosition = lastTime;

  return game.callOnScripts('onKeyPress', [key]);

}

function inputRelease(key:Int):Dynamic {

  if (game.inCutscene || game.paused || game.endingSong ||
  game.cpuControlled || !game.generatedMusic || !game.startedCountdown) {
    return null;
  }

  if (game.callOnScripts('onKeyReleasePre', [key]) == funcStop) {
    return null;
  }

  if (game.guitarHeroSustains) {

    var sustainTbl:Array<Note> = [];
    if (game.notes.members.length != 0) {
      sustainTbl = game.notes.members.filter(function(a:Note):Bool {
        return notNull(a) && a.noteData == key && a.mustPress && !a.tooLate &&
        !a.missed && !a.hitByOpponent && a.spawned && !a.blockHit && a.isSustainNote &&
        a.strumTime > Conductor.songPosition - Conductor.safeZoneOffset * a.lateHitMult &&
        a.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * a.earlyHitMult;
      });
    }

    if (sustainTbl.length != 0) {

      sustainTbl.sort(function(a:Note, b:Note):Int {
        return Std.int(b.strumTime - a.strumTime);
      });

      final tail:Note = sustainTbl[0];
      sustainTbl = [];

      if (notNull(tail) && !StringTools.endsWith(tail.animation.curAnim.name, 'end') &&
      tail.parent.wasGoodHit) {
        game.noteMiss(tail);
      }

    }

  }

  final strum:StrumNote = game.playerStrums.members[key];
  if (notNull(strum) && strum.animation.curAnim.name != 'static') {
    strum.playAnim('static');
    strum.resetAnim = 0;
  }

  return game.callOnScripts('onKeyRelease', [key]);

}

function noteMiss(daNote:Note):Void {

  if (!game.guitarHeroSustains) {
    return;
  }

  final leTail:Array<Note> = daNote.isSustainNote ? daNote.parent.tail : daNote.tail;

  if (daNote.isSustainNote) {
    daNote.blockHit = true;
    daNote.active = false;
    daNote.kill();
  }

  if (leTail.length < 1) {
    return;
  }

  for (tail in leTail) {
    if (notNull(tail)) {
      tail.blockHit = true;
      tail.active = false;
      tail.kill();
    }
  }

  return;

}

function onCreatePost():Void {
  destroyEvents(game.onKeyPress, game.onKeyRelease);
  addEvents(input, input);
  return;
}

function onDestroy():Void {
  destroyEvents(input, input);
  return;
}