import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../techniques/domain/technique.dart';
import '../../techniques/domain/technique_preset.dart';

@immutable
class ActiveSessionConfig {
  const ActiveSessionConfig({
    required this.technique,
    required this.preset,
    required this.presetId,
    required this.durationLimitSeconds,
  });

  final Technique technique;
  final TechniquePreset preset;
  final String presetId;
  final int durationLimitSeconds;
}

final activeSessionConfigProvider =
    NotifierProvider<ActiveSessionConfigController, ActiveSessionConfig?>(
      ActiveSessionConfigController.new,
    );

class ActiveSessionConfigController extends Notifier<ActiveSessionConfig?> {
  @override
  ActiveSessionConfig? build() => null;

  void setConfig(ActiveSessionConfig config) => state = config;

  void clear() => state = null;
}
