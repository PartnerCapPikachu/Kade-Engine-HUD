var kadeIconBops:Bool = true;

function onUpdatePost(elapsed:Float) {
  if (!kadeIconBops) {return;}
  for (i in 0...2) {
    var icon:FlxSprite = i == 0 ? game.iconP1 : game.iconP2;
    if (icon == null) {continue;}
    icon.scale.x = 1;
    icon.origin.x = 50 + (30 * i);
    icon.origin.y = 0;
  }
  return;
}
