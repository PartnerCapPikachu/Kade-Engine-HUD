// startWithCamZooming - If true, sets camZooming to true when the song starts, and not when the opponent starts singing.
// kadeHealthBarColors - If true, the health bar's colors will always be set like in KE.
// kadeCameraSpeed - If true, cameraSpeed is based on framerate, like KE.
// forceDisableSplashes - If true, disables note splashes from appearing, similar to how KE never added them.
// kadeBotplayTxtPosition - If true, botplayTxt basically swaps y positions.
// kadeCharacterHoldTimers - If true, hold timers are based off of the song stepCrochet and don't start at 0.
// kadeNoStrumAnimations - If true, the opponent's strumline doesn't animate. Additionally, the players won't either during botplay.
var miscSettings:Object<Dynamic> = {
  startWithCamZooming: true,
  forceHealthBarColors: true,
  hpColors: {leftColor: 0xffff0000, rightColor: 0xff67fe33},
  kadeCameraSpeed: false,
  forceDisableSplashes: true,
  kadeBotplayTxtPosition: true,
  kadeCharacterHoldTimers: true,
  kadeNoStrumAnimations: false
};

function onCreatePost() {
  game.camZooming = miscSettings.startWithCamZooming;
  if (miscSettings.forceHealthBarColors) {
    game.healthBar.leftBar.color = miscSettings.hpColors.leftColor;
    game.healthBar.rightBar.color = miscSettings.hpColors.rightColor;
  }
  if (miscSettings.kadeCameraSpeed) {
    game.cameraSpeed = 3 * Math.max(0, Math.min(ClientPrefs.data.framerate - 60) / 180, 1);
  }
  game.grpNoteSplashes.visible = !miscSettings.forceDisableSplashes;
  if (miscSettings.kadeBotplayTxtPosition) {
    game.botplayTxt.y += ClientPrefs.data.downScroll ? -450 : 450;
  }
  return;
}

function noteStuff(daNote:Note):Void {
  final character:Character = daNote.gfNote ? game.gf : daNote.mustPress ? game.boyfriend : game.dad;
  if (miscSettings.kadeCharacterHoldTimers && !daNote.noAnimation && character != null) {character.holdTimer = 0.125 + Conductor.bpm / 10000;}
  return;
}

function goodNoteHit(_:Note) {noteStuff(_); return;}
function opponentNoteHit(_:Note) {noteStuff(_); return;}

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
  if (eventName != 'Change Character' || !miscSettings.forceHealthBarColors) {return;}
  game.healthBar.leftBar.color = miscSettings.hpColors.leftColor;
  game.healthBar.rightBar.color = miscSettings.hpColors.rightColor;
  return;
}
