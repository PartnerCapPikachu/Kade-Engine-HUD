import tjson.TJSON.parse;

if (!parse(File.getContent(Paths.mods('KEHUD/modSettings/Icons.json'))).enabled) {
  return;
}

function onUpdatePost(elapsed:Float):Void {
  for (i in 0...2) {
    final icon:FlxSprite = i == 0 ? game.iconP1 : game.iconP2;
    if (icon != null) {
      icon.scale.x = 1;
      icon.origin.set(50 + 30 * i);
    }
  }
  return;
}