import psychlua.LuaUtils.getModSetting;

function hpColors():Void {
  if (getModSetting('KadeHealthBarColors', 'KEHUD')) {
    game.healthBar.leftBar.color = 0xffff0000;
    game.healthBar.rightBar.color = 0xff67fe33;
  }
  return;
}

function onCreatePost():Void {
  game.camZooming = getModSetting('KadeStartWithZooming', 'KEHUD') && PlayState.SONG.song.toLowerCase() != 'tutorial';
  hpColors();
  if (getModSetting('KadeBotplayTextPos', 'KEHUD')) {
    game.botplayTxt.y += ClientPrefs.data.downScroll ? -450 : 450;
  }
  return;
}

if (getModSetting('KadeNoStrumAnimations', 'KEHUD')) {
  function onUpdatePost(elapsed:Float):Void {
    for (strum in game.strumLineNotes.members) {
      if (strum.player == 0 || strum.player == 1 && game.cpuControlled) {
        strum.playAnim('static');
      }
    }
    return;
  }
}

if (getModSetting('KadeCharacterHoldTimers', 'KEHUD')) {
  function noteStuff(daNote:Note):Void {
    final character:Character = daNote.gfNote ? game.gf : daNote.mustPress ? game.boyfriend : game.dad;
    if (!daNote.noAnimation && character != null) {
      character.holdTimer = .125 + Conductor.bpm * .0001;
    }
    return;
  }
  function goodNoteHit(_:Note):Void {
    noteStuff(_);
    return;
  }
  function opponentNoteHit(_:Note):Void {
    noteStuff(_);
    return;
  }
}

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float):Void {
  if (eventName == 'Change Character') {
    hpColors();
  }
  return;
}