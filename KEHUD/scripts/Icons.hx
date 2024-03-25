var fuckedIconBops:Bool = true;

function onUpdatePost(elapsed:Float) {
  if (!fuckedIconBops) {return;}
  for (i in 0...2) {
    var icon:FlxSprite = i == 0 ? game.iconP1 : game.iconP2;
    if (icon == null) {continue;}
    icon.scale.x = 1;
    icon.origin.x = 50 + (i == 1 ? 30 : 0);
    icon.origin.y = 0;
  }
  return;
}