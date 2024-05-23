// not recommended to edit but meh

import openfl.events.KeyboardEvent;
import psychlua.LuaUtils.Function_Stop as funcStop;

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

function simpleSort(a:Note, b:Note):Int {
  return Std.int(b.strumTime - a.strumTime);
}

function sortNotesByPriority(a:Note, b:Note):Int {
  return a.lowPriority && !b.lowPriority ? -1 : !a.lowPriority && b.lowPriority ? 1 : simpleSort(a, b);
}

function input(event:KeyboardEvent):Dynamic {
  if (game.controls.controllerMode) {
    return null;
  }
  final key:Int = getKey(game.keysArray, event.keyCode);
  if (key < 0 || key > game.playerStrums.length - 1) {
    return null;
  }
  final inputFromArray:String = game.keysArray[key];
  final called:String = game.controls.justPressed(inputFromArray) ? 'Press' : game.controls.justReleased(inputFromArray) ? 'Release' : '';
  if (called == '') {
    return null;
  }
  return game.callOnScripts('input' + called, [key]);
}

function inputPress(key:Int):Dynamic {
  if ((game.inCutscene || game.paused || game.endingSong || game.cpuControlled || !game.generatedMusic || !game.startedCountdown) ||
  game.callOnScripts('onKeyPressPre', [key]) == funcStop) {
    return null;
  }
  final lastTime:Float = Conductor.songPosition;
  if (!game.startingSong || lastTime >= 0) {
    Conductor.songPosition = FlxG.sound.music.time;
  }
  var sortedNotesList:Array<Note> = game.notes.members.filter(function(a:Note):Bool {
    return a != null && !game.strumsBlocked[a.noteData] && a.noteData == key && a.mustPress && a.canBeHit && !a.tooLate &&
    !a.wasGoodHit && !a.missed && !a.hitByOpponent && !a.noteWasHit && a.spawned && !a.blockHit && !a.isSustainNote;
  });
  if (sortedNotesList.length != 0) {
    sortedNotesList.sort(sortNotesByPriority);
    final coolNote:Note = sortedNotesList[sortedNotesList.length - 1];
    if (sortedNotesList.length > 1) {
      for (epicNote in sortedNotesList) {
        if (epicNote != coolNote && epicNote.strumTime - coolNote.strumTime <= 12.5 * 100 / Conductor.bpm) {
          game.invalidateNote(epicNote);
        }
      }
    }
    game.goodNoteHit(coolNote);
    sortedNotesList = [];
  } else {
    game.callOnScripts('onGhostTap', [key]);
    if (!ClientPrefs.data.ghostTapping) {
      game.noteMissPress(key);
    }
  }
  final strum:StrumNote = game.playerStrums.members[key];
  if (strum != null && strum.animation.curAnim.name != 'confirm') {
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
  if ((game.inCutscene || game.paused || game.endingSong) || game.callOnScripts('onKeyReleasePre', [key]) == funcStop) {
    return null;
  }
  if (game.guitarHeroSustains) {
    var sustainTbl:Array<Note> = game.notes.members.filter(function(a:Note):Bool {
      return a != null && a.noteData == key && a.mustPress && !a.tooLate && !a.missed &&
      !a.hitByOpponent && a.spawned && !a.blockHit && a.isSustainNote && a.parent.wasGoodHit && !a.wasGoodHit;
    });
    if (sustainTbl.length != 0) {
      sustainTbl.sort(simpleSort);
      final tail:Note = sustainTbl[0];
      game.noteMiss(tail);
      for (t in tail.parent.tail) {
        if (t != null) {
          t.alpha = .35;
          t.multAlpha = .6;
        }
      }
      tail.missed = tail.ignoreNote = tail.tooLate = true;
      tail.canBeHit = false;
      sustainTbl = [];
    }
  }
  final strum:StrumNote = game.playerStrums.members[key];
  if (strum != null && strum.animation.curAnim.name != 'static') {
    strum.playAnim('static');
    strum.resetAnim = 0;
  }
  return game.callOnScripts('onKeyRelease', [key]);
}

function onCreatePost():Void {
  FlxG.stage.removeEventListener('keyDown', game.onKeyPress);
  FlxG.stage.removeEventListener('keyUp', game.onKeyRelease);
  FlxG.stage.addEventListener('keyDown', input);
  FlxG.stage.addEventListener('keyUp', input);
  return;
}

function onDestroy():Void {
  FlxG.stage.removeEventListener('keyDown', input);
  FlxG.stage.removeEventListener('keyUp', input);
  return;
}