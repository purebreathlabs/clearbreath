import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final shareCardRendererProvider = Provider<ShareCardRenderer>((ref) {
  return const ShareCardRenderer();
});

class ShareCardRenderer {
  const ShareCardRenderer();

  Future<Uint8List> renderPngBytes(
    GlobalKey repaintBoundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    final context = repaintBoundaryKey.currentContext;
    final renderObject = context?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('Share card is not ready.');
    }

    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Could not encode share image.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<File> writePngToTemp(
    Uint8List bytes, {
    String filename = 'clearbreath_share.png',
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> sharePngFile(File file, {String? text}) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: text),
    );
  }

  Future<void> renderAndShare(
    GlobalKey repaintBoundaryKey, {
    double pixelRatio = 3.0,
    String filename = 'clearbreath_share.png',
    String? text,
  }) async {
    final bytes = await renderPngBytes(
      repaintBoundaryKey,
      pixelRatio: pixelRatio,
    );
    final file = await writePngToTemp(bytes, filename: filename);
    await sharePngFile(file, text: text);
  }
}
