final options:Object<Bool> = {
  healthColors: getModSetting('KadeHealthBarColors', 'KEHUD'),
  startWithZooming: getModSetting('KadeStartWithZooming', 'KEHUD') && PlayState.SONG.song.toLowerCase() != 'tutorial',
  newBotplayPos: getModSetting('KadeBotplayTextPos', 'KEHUD'),
  staticStrums: getModSetting('KadeNoStrumAnimations', 'KEHUD'),
  newCharTimes: getModSetting('KadeCharacterHoldTimers', 'KEHUD')
};

function hpColors():Void {
  if (options.healthColors) {
    game.healthBar.leftBar.color = 0xffff0000;
    game.healthBar.rightBar.color = 0xff67fe33;
  }
  return;
}

function onCreatePost():Void {
  game.camZooming = options.startWithZooming;
  hpColors();
  if (options.newBotplayPos) {
    game.botplayTxt.y += ClientPrefs.data.downScroll ? -450 : 450;
  }
  return;
}

if (options.staticStrums) {

  function onUpdatePost(elapsed:Float):Void {
    for (strum in game.strumLineNotes.members) {
      if (strum.player == 0 || strum.player == 1 && game.cpuControlled) {
        strum.playAnim('static');
      }
    }
    return;
  }

}

if (options.newCharTimes) {

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