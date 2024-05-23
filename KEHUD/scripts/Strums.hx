import psychlua.LuaUtils.getModSetting;
import flixel.group.FlxTypedSpriteGroup;

// basically you can do whatever to the strums AS A WHOLE
// for example, you can set a shader to this grp without doing it to each individual strum note
final strumGrp:FlxTypedSpriteGroup = new FlxTypedSpriteGroup();

function onCountdownStarted():Void {
  for (s in game.strumLineNotes.members) {
    strumGrp.add(s);
  }
  if (getModSetting('KadeNewStrumPosition', 'KEHUD')) {
    for (i in 0...4) {
      final oppStrum:StrumNote = game.opponentStrums.members[i];
      final plrStrum:StrumNote = game.playerStrums.members[i];
      final kadeAmt:Int = getModSetting('KadeStrumPosition', 'KEHUD') ? 56 : 0;
      final subt:Int = 112 * i + 1 - kadeAmt;
      var xToUseOpp:Float = 112 + subt;
      var xToUsePlr:Float = FlxG.width - 560 + subt;
      if (ClientPrefs.data.middleScroll) {
        xToUseOpp = i > 1 ? FlxG.width - 112 * (5 - i) - kadeAmt : 112 + subt;
        xToUsePlr = FlxG.width * .5 - 224 + subt;
      }
      var yToUseOpp:Float = oppStrum.height * .5;
      var yToUsePlr:Float = plrStrum.height * .5;
      if (ClientPrefs.data.downScroll) {
        yToUseOpp = FlxG.height - oppStrum.height - oppStrum.height * .5;
        yToUsePlr = FlxG.height - plrStrum.height - plrStrum.height * .5;
      }
      oppStrum.setPosition(xToUseOpp, yToUseOpp);
      plrStrum.setPosition(xToUsePlr, yToUsePlr);
    }
  } else if (getModSetting('KadeStrumPosition', 'KEHUD')) {
    strumGrp.x -= 56;
  }
  return;
}