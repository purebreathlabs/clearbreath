import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_status.dart';
import 'connection_status_provider.dart';

final serverStatusProvider = StreamProvider.autoDispose<bool>((ref) {
  final controller = StreamController<bool>();

  ref.listen(connectionStatusProvider, (prev, next) {
    final status = next.asData?.value.status;
    if (status != null) {
      controller.add(status == ConnectionStatus.online);
    }
  });

  ref.onDispose(controller.close);

  return controller.stream.distinct();
});
