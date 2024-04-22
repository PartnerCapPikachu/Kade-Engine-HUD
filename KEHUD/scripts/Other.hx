import tjson.TJSON.parse;
import backend.CoolUtil;

final path:String = Paths.mods('KEHUD/modSettings/Other.json');
var destroyScript:Bool = false;

if (!FileSystem.exists(path)) {
  destroyScript = true;
  debugPrint('Other.hx (ERROR): Failed to find settings json for script.\n  Aborting script to save Psych performance.', 0xffff0000);
}

if (destroyScript) {
  return game.hscriptArray.remove(game.hscriptArray[game.hscriptArray.indexOf(this)]);
}

final miscSettings = parse(File.getContent(path));

function onCreatePost():Void {

  game.camZooming = miscSettings.startWithCamZooming && PlayState.SONG.song.toLowerCase() != 'tutorial';

  if (miscSettings.forceHealthBarColors) {
    game.healthBar.leftBar.color = CoolUtil.colorFromString(miscSettings.hpColors.leftColor);
    game.healthBar.rightBar.color = CoolUtil.colorFromString(miscSettings.hpColors.rightColor);
  }

  game.grpNoteSplashes.visible = !miscSettings.forceDisableSplashes;

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