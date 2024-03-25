// Uncomment if you're using a pixel-based font. Any font might be recommended though. (+ lines 8-16)
// import openfl.Lib.application;

import Main.fpsVar;
import openfl.text.TextFormat;
import flixel.util.FlxStringUtil.formatBytes;

/*
function trueTextScale(?number:Null<Float>):Int {
  number ??= 12;
  final remain:Float = number % 12;
  if (remain != 0) {number += 12 - remain;}
  final bounds:Rectangle = application.window.display.bounds;
  return Math.ceil(number * Math.min(FlxG.width / bounds.width, FlxG.height / bounds.height));
}
*/

final oldOffset:Array<Float> = [fpsVar.x, fpsVar.y];
// Uncomment these and then set the x and y to whatever you want.
// For simplicity, if both use the same x and y, do:
//    - fpsVar.x = fpsVar.y = float/int;
// fpsVar.x = 0;
// fpsVar.y = 0;

final oldFormat:TextFormat = fpsVar.defaultTextFormat;
// Uncomment this. Change each to what you need.
// scale equals size of the text (float/int)
// fpsVar.defaultTextFormat = new TextFormat('example.ttf', scale, 0xff00000);

// Before the function is changed, store it here.
// Set it back when state is destroyed or reloaded.
final oldUpdate:Dynamic = fpsVar.updateText;
// Uncomment below and edit.
//var times:Array<Float> = [];
//var avr:Float = 0;
//fpsVar.updateText = function() {
//  times.push(FlxG.elapsed);
//  var total:Float = 0;
//  for (time in times) {total += time * 1000;}
//  avr = Math.floor(total / times.length);
//  if (times.length >= FlxG.drawFramerate) {times = [];}
//  fpsVar.text = 'FPS: ' + fpsVar.currentFPS + ' [' + avr + 'MS]\nGCM: ' + formatBytes(fpsVar.memoryMegas);
//  fpsVar.textColor = fpsVar.currentFPS < FlxG.drawFramerate * 0.5 ? 0xff0000 : 0xffffffff;
//  return;
//}

function onDestroy() {
  fpsVar.x = oldOffset[0];
  fpsVar.y = oldOffset[1];
  fpsVar.defaultTextFormat = oldFormat;
  fpsVar.updateText = oldUpdate;
  return;
}