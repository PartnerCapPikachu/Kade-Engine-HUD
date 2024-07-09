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

function input(event:KeyboardEvent):Void {
  final lastTime:Float = Conductor.songPosition;
  final key:Int = getKey(game.keysArray, event.keyCode);
  final k:String = game.keysArray[key];
  final strum:StrumNote = game.playerStrums.members[key];
  if (!game.controls.controllerMode && (key > -1 || key < game.playerStrums.length)) {
    if (game.controls.justPressed(k)) {
      if ((!game.inCutscene && !game.paused && !game.endingSong && !game.cpuControlled && game.generatedMusic && game.startedCountdown) &&
      game.callOnScripts('onKeyPressPre', [key]) != funcStop) {
        if (!game.startingSong || lastTime >= 0) {
          Conductor.songPosition = FlxG.sound.music.time;
        }
        var sortedNotesList:Array<Note> = game.notes.members.filter(function(a:Note):Bool {
          return a != null && a.noteData == key && a.mustPress && a.canBeHit && !a.tooLate &&
          !a.wasGoodHit && !a.missed && !a.hitByOpponent && !a.noteWasHit && a.spawned && !a.blockHit && !a.isSustainNote;
        });
        if (sortedNotesList.length != 0 && game.strumsBlocked[key]) {
          sortedNotesList.sort(sortNotesByPriority);
          game.goodNoteHit(sortedNotesList[sortedNotesList.length - 1]);
          sortedNotesList = [];
        } else if (sortedNotesList.length == 0) {
          game.callOnScripts('onGhostTap', [key]);
          if (!ClientPrefs.data.ghostTapping) {
            game.noteMissPress(key);
          }
        }
        if (!game.keysPressed.contains(key)) {
          game.keysPressed.push(key);
        }
        if (strum != null && strum.animation.curAnim.name != 'confirm') {
          strum.playAnim('pressed');
          strum.resetAnim = 0;
        }
        Conductor.songPosition = lastTime;
        game.callOnScripts('onKeyPress', [key]);
      }
    } else if (game.controls.justReleased(k)) {
      if ((!game.inCutscene && !game.paused && !game.endingSong) &&
      game.callOnScripts('onKeyReleasePre', [key]) != funcStop) {
        if (game.guitarHeroSustains) {
          var sustainTbl:Array<Note> = game.notes.members.filter(function(a:Note):Bool {
            return a != null && a.noteData == key && a.mustPress && !a.tooLate && !a.missed &&
            !a.hitByOpponent && a.spawned && !a.blockHit && a.isSustainNote && a.parent.wasGoodHit && !a.wasGoodHit;
          });
          if (sustainTbl.length != 0) {
            sustainTbl.sort(simpleSort);
            game.noteMiss(sustainTbl[0]);
            sustainTbl = [];
          }
        }
        if (strum != null && strum.animation.curAnim.name != 'static') {
          strum.playAnim('static');
          strum.resetAnim = 0;
        }
        game.callOnScripts('onKeyRelease', [key]);
      }
    }
  }
  return;
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
