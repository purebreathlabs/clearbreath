import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/audio_cue_service.dart';

class SessionAudioControls extends ConsumerStatefulWidget {
  const SessionAudioControls({super.key});

  @override
  ConsumerState<SessionAudioControls> createState() =>
      _SessionAudioControlsState();
}

class _SessionAudioControlsState extends ConsumerState<SessionAudioControls> {
  late bool _muted;
  late double _volume;

  @override
  void initState() {
    super.initState();
    final audio = ref.read(audioCueServiceProvider);
    _muted = audio.isMuted;
    _volume = audio.volume;
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioCueServiceProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final maxHeight = spacing.sm * 2 + kMinInteractiveDimension;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(spacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(components.cardRadius),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            IconButton(
              key: const Key('session_mute_toggle'),
              onPressed: () {
                setState(() => _muted = !_muted);
                if (_muted) {
                  audio.mute();
                } else {
                  audio.unmute();
                }
              },
              icon: Icon(
                _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: colors.textPrimary,
              ),
              tooltip: _muted ? 'Unmute' : 'Mute',
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: colors.textPrimary,
                  inactiveTrackColor: colors.surfaceHigh,
                  thumbColor: colors.textPrimary,
                ),
                child: Slider(
                  key: const Key('session_volume_slider'),
                  value: _muted ? 0 : _volume,
                  onChanged: (value) {
                    final next = value.clamp(0.0, 1.0);
                    setState(() {
                      _muted = false;
                      _volume = next;
                    });
                    audio.unmute();
                    audio.setVolume(next);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
