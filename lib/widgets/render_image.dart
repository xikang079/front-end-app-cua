import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<Uint8List> createImageFromText(String text, {double width = 200}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  const textStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontFamily: 'Roboto',
  );

  final textSpan = TextSpan(
    text: text,
    style: textStyle,
  );

  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(
    minWidth: 0,
    maxWidth: width,
  );

  final textHeight = textPainter.size.height;
  final textWidth = textPainter.size.width;

  canvas.drawRect(Rect.fromLTWH(0, 0, textWidth, textHeight), paint);

  textPainter.paint(canvas, const Offset(0, 0));

  final picture = recorder.endRecording();
  final img = await picture.toImage(textWidth.toInt(), textHeight.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
