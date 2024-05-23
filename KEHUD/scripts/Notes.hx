import psychlua.LuaUtils.getModSetting;

var onDestroySustainSize:Int = 44;
var pixelSustainSize:Float = 1;

if (getModSetting('KadeSustainsEnabled', 'KEHUD')) {
  onDestroySustainSize = Note.SUSTAIN_SIZE;
  Note.SUSTAIN_SIZE = getModSetting('KadeSustainScale', 'KEHUD');
  if (PlayState.isPixelStage) {
    pixelSustainSize = Note.SUSTAIN_SIZE / onDestroySustainSize;
  }
}

function onCountdownStarted():Void {
  for (strum in game.strumLineNotes.members) {
    strum.sustainReduce = !getModSetting('KadeSustainCliprectEnabled', 'KEHUD');
  }
  return;
}

function onSpawnNote(daNote:Note):Void {
  if (daNote.isSustainNote) {
    if (getModSetting('KadeSustainAlpha', 'KEHUD')) {
      daNote.multAlpha = 1;
    }
    if (getModSetting('KadeSustainsEnabled', 'KEHUD') && PlayState.isPixelStage) {
      daNote.scale.y *= pixelSustainSize;
    }
  }
  return;
}

function handleNoteVis(daNote:Note):Void {
  if (daNote.isSustainNote) {
    final strum:StrumNote = daNote.mustPress ? game.playerStrums.members[daNote.noteData] : game.opponentStrums.members[daNote.noteData];
    daNote.visible = strum.sustainReduce;
  }
  return;
}

function goodNoteHit(_:Note):Void {
  handleNoteVis(_);
  return;
}

function opponentNoteHit(_:Note):Void {
  handleNoteVis(_);
  return;
}

function onDestroy() {
  Note.SUSTAIN_SIZE = onDestroySustainSize;
  return;
}