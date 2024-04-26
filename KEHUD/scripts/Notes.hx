import tjson.TJSON.parse;

final noteSettings = parse(File.getContent(Paths.mods('KEHUD/modSettings/Notes.json')));

if (noteSettings.kadeSustains) {
  noteSettings.onDestroySustainSize = Note.SUSTAIN_SIZE;
  Note.SUSTAIN_SIZE = noteSettings.customSustainSize;
  if (PlayState.isPixelStage) {
    noteSettings.pixelSustainSize = Note.SUSTAIN_SIZE / noteSettings.onDestroySustainSize;
  }
}

noteSettings.onDestroyNoteOffset = ClientPrefs.data.noteOffset;
if (ClientPrefs.data.noteOffset != noteSettings.newNoteOffset) {
  ClientPrefs.data.noteOffset = noteSettings.newNoteOffset;
}

function onCountdownStarted():Void {
  for (strum in game.strumLineNotes.members) {
    strum.sustainReduce = !noteSettings.noCliprect;
  }
  return;
}

function onSpawnNote(daNote:Note):Void {
  if (daNote.isSustainNote) {
    if (noteSettings.allowFullAlphaSustains) {
      daNote.multAlpha = 1;
    }
    if (noteSettings.kadeSustains && PlayState.isPixelStage) {
      daNote.scale.y *= noteSettings.pixelSustainSize;
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
  Note.SUSTAIN_SIZE = noteSettings.onDestroySustainSize;
  ClientPrefs.data.noteOffset = noteSettings.onDestroyNoteOffset;
  return;
}