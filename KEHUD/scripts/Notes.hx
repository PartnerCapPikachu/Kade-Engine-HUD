// kadeSustains - If true, sustain length is altered to look like kade.
// onDestroySustainSize - Resets the sustain size int.
// customSustainSize - The specific size you'd like it to be if kadeSustains is true. Must be an int.
// onDestroyNoteOffset - Resets the global note offset.
// newNoteOffset - The specific offset you'd like the notes to be delayed by. Must be an int.
// noCliprect - If true, the strum's cliprect for sustain being help is turned off when loaded and sustains will just have their visible setting turned to false.
// allowFullAlphaSustains - If true, sustain copyAlpha is disabled and their multAlpha becomes 1.
var noteSettings:Object<Dynamic> = {
  kadeSustains: true,
  onDestroySustainSize: 0,
  customSustainSize: 22,
  onDestroyNoteOffset: 0,
  newNoteOffset: 0,
  noCliprect: true,
  allowFullAlphaSustains: true
};

if (noteSettings.kadeSustains) {
  noteSettings.onDestroySustainSize = Note.SUSTAIN_SIZE;
  Note.SUSTAIN_SIZE = noteSettings.customSustainSize;
}

noteSettings.onDestroyNoteOffset = ClientPrefs.data.noteOffset;
if (ClientPrefs.data.noteOffset != noteSettings.newNoteOffset) {
  ClientPrefs.data.noteOffset = noteSettings.newNoteOffset;
}

function onCountdownStarted() {
  for (strum in game.strumLineNotes.members) {
    strum.sustainReduce = !noteSettings.noCliprect;
  }
  return;
}

function onSpawnNote(daNote:Note) {
  if (!daNote.isSustainNote) {return;}
  if (noteSettings.allowFullAlphaSustains) {daNote.multAlpha = 1;}
  if (noteSettings.kadeSustains && PlayState.isPixelStage) {daNote.scale.y /= 2;}
  return;
}

function goodNoteHit(daNote:Note) {
  if (!daNote.isSustainNote) {return;}
  daNote.visible = game.playerStrums.members[daNote.noteData].sustainReduce;
  return;
}

function opponentNoteHit(daNote:Note) {
  if (!daNote.isSustainNote) {return;}
  daNote.visible = game.opponentStrums.members[daNote.noteData].sustainReduce;
  return;
}

function onDestroy() {
  Note.SUSTAIN_SIZE = noteSettings.onDestroySustainSize;
  ClientPrefs.data.noteOffset = noteSettings.onDestroyNoteOffset;
  return;
}