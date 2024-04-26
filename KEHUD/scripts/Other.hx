import tjson.TJSON.parse;
import backend.CoolUtil;

final miscSettings = parse(File.getContent(Paths.mods('KEHUD/modSettings/Other.json')));

function onCreatePost():Void {
  game.camZooming = miscSettings.startWithCamZooming && PlayState.SONG.song.toLowerCase() != 'tutorial';
  game.grpNoteSplashes.visible = game.grpNoteSplashes.visible && !miscSettings.forceDisableSplashes;
  if (miscSettings.forceHealthBarColors) {
    game.healthBar.leftBar.color = CoolUtil.colorFromString(miscSettings.hpColors.leftColor ??= '0xffff0000');
    game.healthBar.rightBar.color = CoolUtil.colorFromString(miscSettings.hpColors.rightColor ??= '0xff67fe33');
  }
  if (miscSettings.kadeBotplayTxtPosition) {
    game.botplayTxt.y += ClientPrefs.data.downScroll ? -450 : 450;
  }
  return;
}

function noteStuff(daNote:Note):Void {
  final character:Character = daNote.gfNote ? game.gf : daNote.mustPress ? game.boyfriend : game.dad;
  if (miscSettings.kadeCharacterHoldTimers && !daNote.noAnimation && character != null) {
    character.holdTimer = 0.125 + Conductor.bpm * 0.0001;
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

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float):Void {
  if (eventName == 'Change Character' && miscSettings.forceHealthBarColors) {
    game.healthBar.leftBar.color = CoolUtil.colorFromString(miscSettings.hpColors.leftColor);
    game.healthBar.rightBar.color = CoolUtil.colorFromString(miscSettings.hpColors.rightColor);
  }
  return;
}