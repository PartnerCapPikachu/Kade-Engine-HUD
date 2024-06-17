var onDestroySustainSize:Int = 44;
var pixelSustainSize:Float = 1;

final options:Object<Bool> = {
  kadeSustains: getModSetting('KadeSustainsEnabled', 'KEHUD'),
  kadeSustainScale: getModSetting('KadeSustainScale', 'KEHUD'),
  kadeSustainCliprect: !getModSetting('KadeSustainCliprectEnabled', 'KEHUD'),
  kadeSustainFullAlpha: getModSetting('KadeSustainAlpha', 'KEHUD')
};

if (options.kadeSustains) {
  onDestroySustainSize = Note.SUSTAIN_SIZE;
  Note.SUSTAIN_SIZE = options.kadeSustainScale;
  if (PlayState.isPixelStage) {
    pixelSustainSize = Note.SUSTAIN_SIZE / onDestroySustainSize;
  }
}

function onCountdownStarted():Void {
  for (strum in game.strumLineNotes.members) {
    strum.sustainReduce = options.kadeSustainCliprect;
  }
  return;
}

function onSpawnNote(daNote:Note):Void {
  if (daNote.isSustainNote) {
    if (options.kadeSustainFullAlpha) {
      daNote.multAlpha = 1;
    }
    if (options.kadeSustains && PlayState.isPixelStage) {
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