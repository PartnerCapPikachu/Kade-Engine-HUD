import tjson.TJSON.parse;

final strumSettings = parse(File.getContent(Paths.mods('KEHUD/modSettings/Strums.json')));

function onCountdownStarted():Void {
  for (i in 0...4) {
    if (strumSettings.useNewStrumPosition) {
      final kadeAmt:Int = strumSettings.kadeStrumPosition ? 56 : 0;
      final subt:Int = 112 * i + 1 - kadeAmt;
      var xToUseOpp:Float = 112 + subt;
      var xToUsePlr:Float = FlxG.width - 560 + subt;
      if (ClientPrefs.data.middleScroll) {
        xToUseOpp = i > 1 ? FlxG.width - 112 * (5 - i) - kadeAmt : 112 + subt;
        xToUsePlr = FlxG.width * 0.5 - 224 + subt;
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
      if (!strumSettings.kadeStrumPosition) {
        break;
      }
      game.opponentStrums.members[i].x -= 56;
      game.playerStrums.members[i].x -= 56;
    }
  }
  return;
}