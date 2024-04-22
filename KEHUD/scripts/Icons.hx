import tjson.TJSON.parse;

final path:String = Paths.mods('KEHUD/modSettings/Icons.json');
var destroyScript:Bool = false;

if (!FileSystem.exists(path)) {
  destroyScript = true;
  debugPrint('Icons.hx (ERROR): Failed to find settings json for script.\n  Aborting script to save Psych performance.', 0xffff0000);
} else if (!parse(File.getContent(path)).enabled) {
  destroyScript = true;
}

if (destroyScript) {
  return game.hscriptArray.remove(game.hscriptArray[game.hscriptArray.indexOf(this)]);
}

function onUpdatePost(elapsed:Float):Void {
  for (i in 0...2) {
    final icon:FlxSprite = i == 0 ? game.iconP1 : game.iconP2;
    if (icon != null) {
      icon.scale.x = 1;
      icon.origin.x = 50 + 30 * i;
      icon.origin.y = 0;
    }
  }
  return;
}