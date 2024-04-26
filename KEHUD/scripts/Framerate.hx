import openfl.Lib.application;
import Main.fpsVar;
import openfl.text.TextFormat;
import flixel.util.FlxStringUtil.formatBytes;

// remove this line if you wanna actually use this script
// it just prevents this script from running what's below
return;

function trueTextScale(?number:Null<Float>):Int {
  number ??= 12;
  final remain:Float = number % 12;
  if (remain != 0) {
    number += 12 - remain;
  }
  final bounds:Rectangle = application.window.display.bounds;
  return Math.ceil(number * Math.min(FlxG.width / bounds.width, FlxG.height / bounds.height));
}

final oldOffset:Array<Float> = [fpsVar.x, fpsVar.y];
// fpsVar.x = fpsVar.y = 0;

final oldFormat:TextFormat = fpsVar.defaultTextFormat;
// fpsVar.defaultTextFormat = new TextFormat('example.ttf', scale, 0xff00000);

final oldUpdate:Dynamic = fpsVar.updateText;
var times:Array<Float> = [];
var avr:Float = 0;
fpsVar.updateText = () -> {

  times.push(FlxG.elapsed);

  var total:Float = 0;
  for (time in times) {
    total += time * 1000;
  }

  avr = Math.floor(total / times.length);

  if (times.length >= FlxG.drawFramerate) {
    times = [];
  }

  fpsVar.text = 'FPS: ' + fpsVar.currentFPS + ' [' + avr + 'MS]\nGCM: ' + formatBytes(fpsVar.memoryMegas);
  fpsVar.textColor = fpsVar.currentFPS < FlxG.drawFramerate * 0.5 ? 0xff0000 : 0xffffffff;

  return;

}

function onDestroy():Void {
  fpsVar.x = oldOffset[0];
  fpsVar.y = oldOffset[1];
  fpsVar.defaultTextFormat = oldFormat;
  fpsVar.updateText = oldUpdate;
  return;
}