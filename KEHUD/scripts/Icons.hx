import psychlua.LuaUtils.getModSetting;

if (getModSetting('KadeIconBopEnabled', 'KEHUD')) {
  game.updateIconsScale = (elapsed:Float) -> {
    for (i in [game.iconP1, game.iconP2]) {
      i.scale.set(1, 1); // icon scale is set to 1.2 for x and y; revert
      i.setGraphicSize(180); // scale was set to itself + 30, so 180
      i.setGraphicSize(FlxMath.lerp(150, i.width, .5)); // actual lerp from kade playstate
      i.updateHitbox(); // yeah
    }
  }
}