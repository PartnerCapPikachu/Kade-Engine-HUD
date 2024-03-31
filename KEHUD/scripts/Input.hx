// not recommended to edit but meh

import psychlua.LuaUtils.Function_Stop as funcStop;

function addEvents(a, b):Void {for (c in [['Down', a], ['Up', b]]) {if (c[1] != null) {FlxG.stage.addEventListener('key' + c[0], c[1]);}} return;}
function destroyEvents(a, b):Void {for (c in [['Down', a], ['Up', b]]) {if (c[1] != null) {FlxG.stage.removeEventListener('key' + c[0], c[1]);}} return;}

function notNull(a:Any):Bool {
  return a != null && a.exists && a.active;
}

function getKey(tbl:Array<String>, code:Int):Int {
  var leKey:Int = -1;
  if (code == leKey) {return code;}
  for (index in 0...tbl.length) {
    if (ClientPrefs.keyBinds[tbl[index]].indexOf(code) == leKey) {continue;}
    leKey = index;
    break;
  }
  return leKey;
}

function input(event:openfl.events.KeyboardEvent):Void {
  if (game.controls.controllerMode) {return;}
  final key:Int = getKey(game.keysArray, event.keyCode);
  if (key > game.playerStrums.length || key < 0) {return;}
  final called:String = game.controls.justPressed(game.keysArray[key]) ? 'Press' : game.controls.justReleased(game.keysArray[key]) ? 'Release' : '';
  if (called == '') {return;}
  game.callOnScripts('input' + called, [key]);
  return;
}

function inputPress(key:Int) {
  if (game.inCutscene || game.paused || game.endingSong || game.cpuControlled || !game.generatedMusic || !game.startedCountdown ||
  (notNull(game.boyfriend) && game.boyfriend.stunned) || game.strumsBlocked[key]) {return;}
  final keyPreCheck:Dynamic = game.callOnScripts('onKeyPressPre', [key]);
  if (keyPreCheck == funcStop) {return;}
  final lastTime:Float = Conductor.songPosition;
  if (!game.startingSong || lastTime >= 0) {Conductor.songPosition = FlxG.sound.music.time;}
  var sortedNotesList:Array<Note> = [];
  if (game.notes.members.length != 0) {
    sortedNotesList = game.notes.members.filter(
      (a:Note) -> {
        return notNull(a) && a.noteData == key && a.mustPress && a.canBeHit && !a.tooLate && !a.wasGoodHit &&
        !a.missed && !a.hitByOpponent && !a.noteWasHit && a.spawned && !a.blockHit && !a.isSustainNote;
      }
    );
  }
  if (sortedNotesList.length != 0) {
    sortedNotesList.sort((a:Note, b:Note) -> {return a.lowPriority && !b.lowPriority ? -1 : !a.lowPriority && b.lowPriority ? 1 : Std.int(b.strumTime - a.strumTime);});
    final coolNote:Note = sortedNotesList[sortedNotesList.length - 1];
    if (sortedNotesList.length > 1) {
      for (epicNote in sortedNotesList) {
        if (!(notNull(epicNote) && notNull(coolNote) && epicNote != coolNote &&
        epicNote.strumTime - coolNote.strumTime <= 12.5 * (100 / Conductor.bpm))) {continue;}
        game.invalidateNote(epicNote);
      }
    }
    if (notNull(coolNote)) {game.goodNoteHit(coolNote);}
    sortedNotesList = [];
  } else {
    game.callOnScripts('onGhostTap', [key]);
    if (!ClientPrefs.data.ghostTapping) {game.noteMissPress(key);}
  }
  final strum:StrumNote = game.playerStrums.members[key];
  if (notNull(strum) && strum.animation.curAnim.name != 'confirm') {
    strum.playAnim('pressed');
    strum.resetAnim = 0;
  }
  if (!game.keysPressed.contains(key)) {game.keysPressed.push(key);}
  Conductor.songPosition = lastTime;
  game.callOnScripts('onKeyPress', key);
  return;
}

function inputRelease(key:Int) {
  if (game.inCutscene || game.paused || game.endingSong ||
  game.cpuControlled || !game.generatedMusic || !game.startedCountdown) {return;}
  final keyPreCheck:Dynamic = game.callOnScripts('onKeyReleasePre', [key]);
  if (keyPreCheck == funcStop) {return;}
  if (game.guitarHeroSustains) {
    var sustainTbl:Array<Note> = [];
    if (game.notes.members.length != 0) {
      sustainTbl = game.notes.members.filter(
        (a:Note) -> {
          return notNull(a) && a.noteData == key && a.mustPress && a.canBeHit && !a.tooLate &&
          !a.missed && !a.hitByOpponent && a.spawned && !a.blockHit && a.isSustainNote;
        }
      );
    }
    if (sustainTbl.length != 0) {
      sustainTbl.sort((a:Note, b:Note) -> {return Std.int(b.strumTime - a.strumTime);});
      final tail:Note = sustainTbl[0];
      if (notNull(tail) && !StringTools.endsWith(tail.animation.curAnim.name, 'end') && tail.parent.wasGoodHit) {
        game.noteMiss(tail);
      }
      sustainTbl = [];
    }
  }
  final strum:StrumNote = game.playerStrums.members[key];
  if (notNull(strum) && strum.animation.curAnim.name != 'static') {
    strum.playAnim('static');
    strum.resetAnim = 0;
  }
  game.callOnScripts('onKeyRelease', [key]);
  return;
}

function onCreatePost() {
  destroyEvents(game.onKeyPress, game.onKeyRelease);
  addEvents(input, input);
  return;
}

function noteMiss(daNote:Note) {
  if (!game.guitarHeroSustains) {return;}
  var leTail:Array<Note> = daNote.isSustainNote ? daNote.parent.tail : daNote.tail;
  if (leTail.length < 1) {return;}
  for (tail in leTail) {
    if (!notNull(tail)) {continue;}
    game.invalidateNote(tail);
  }
  return;
}

function onDestroy() {
  destroyEvents(input, input);
  return;
}
