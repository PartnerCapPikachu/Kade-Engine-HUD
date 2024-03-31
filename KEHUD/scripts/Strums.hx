// useNewStrumPosition - If true, strum positions get replaced.
// kadeStrumPosition - If true, strums' x axis is altered like KE. Works with useNewStrumPosition.
var strumSettings:Object<Dynamic> = {
  useNewStrumPosition: true,
  kadeStrumPosition: true
};

function onCountdownStarted() {
  for (i in 0...4) {
    if (strumSettings.useNewStrumPosition) {
      final mult:Int = 112 * i + 1;
      final kadeAmt:Int = strumSettings.kadeStrumPosition ? 56 : 0;
      var xToUseOpp:Float = 112 + mult - kadeAmt;
      var xToUsePlr:Float = FlxG.width - 560 + mult - kadeAmt;
      if (ClientPrefs.data.middleScroll) {
        xToUseOpp = i > 1 ? FlxG.width - 560 : 112 + mult;
        xToUsePlr = screenWidth * 0.5 - 224 + mult;
      }
      var yToUseOpp:Float = game.opponentStrums.members[i].height * 0.5;
      var yToUsePlr:Float = game.playerStrums.members[i].height * 0.5;
      if (ClientPrefs.data.downScroll) {
        yToUseOpp = FlxG.height - game.opponentStrums.members[i].height - game.opponentStrums.members[i].height * 0.5;
        yToUsePlr = FlxG.height - game.playerStrums.members[i].height - game.playerStrums.members[i].height * 0.5;
      }
      game.opponentStrums.members[i].x = xToUseOpp;
      game.opponentStrums.members[i].y = yToUseOpp;
      game.playerStrums.members[i].x = xToUsePlr;
      game.playerStrums.members[i].y = yToUsePlr;
    } else {
      if (!strumSettings.kadeStrumPosition) {break;}
      game.opponentStrums.members[i].x -= 56;
      game.playerStrums.members[i].x -= 56;
    }
  }
  return;
}
