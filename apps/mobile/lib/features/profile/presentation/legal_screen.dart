import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_extensions.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>()!;
    final typography = Theme.of(context).extension<AppTypographyTokens>()!;
    final colors = Theme.of(context).extension<AppColorTokens>()!;
    final components = Theme.of(context).extension<AppComponentTokens>()!;

    final config = _config(type);
    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Legal')),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Text(
              'Document not found.',
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
        ),
      );
    }

    void showMessage(String message) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: typography.bodyMedium.copyWith(color: colors.inverseText),
          ),
          backgroundColor: colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(components.buttonRadius),
          ),
        ),
      );
    }

    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: typography.bodyMedium.copyWith(color: colors.textSecondary),
      h1: typography.titleLarge.copyWith(color: colors.textPrimary),
      h2: typography.titleMedium.copyWith(color: colors.textPrimary),
      h3: typography.titleMedium.copyWith(color: colors.textPrimary),
      a: typography.bodyMedium.copyWith(color: colors.focus),
      blockquote: typography.bodyMedium.copyWith(color: colors.textSecondary),
      listBullet: typography.bodyMedium.copyWith(color: colors.textSecondary),
      strong: typography.bodyMedium.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(config.title)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder<String>(
                  future: config.loadMarkdown(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Could not load document.',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      );
                    }
                    final data = snapshot.data ?? '';
                    return Markdown(
                      data: data,
                      styleSheet: styleSheet,
                      selectable: true,
                    );
                  },
                ),
              ),
              if (config.latestUrl != null) ...[
                SizedBox(height: spacing.md),
                OutlinedButton(
                  onPressed: () async {
                    final url = config.latestUrl;
                    if (url == null) {
                      return;
                    }
                    try {
                      final ok = await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                      if (!ok) {
                        showMessage('Could not open link.');
                      }
                    } catch (_) {
                      showMessage('Could not open link.');
                    }
                  },
                  child: const Text('Latest version'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

_LegalConfig? _config(String type) {
  return switch (type) {
    'privacy' => const _LegalConfig(
      title: 'Privacy Policy',
      assetPath: 'assets/legal/privacy.md',
      latestUrl: 'https://clearbreath.life/privacy',
    ),
    'terms' => const _LegalConfig(
      title: 'Terms of Service',
      assetPath: 'assets/legal/terms.md',
      latestUrl: 'https://clearbreath.life/terms',
    ),
    'disclaimer' => const _LegalConfig(
      title: 'Disclaimer',
      assetPath: null,
      latestUrl: null,
    ),
    _ => null,
  };
}

class _LegalConfig {
  const _LegalConfig({
    required this.title,
    required this.assetPath,
    required this.latestUrl,
  });

  final String title;
  final String? assetPath;
  final String? latestUrl;

  Future<String> loadMarkdown() async {
    final path = assetPath;
    if (path == null) {
      return _disclaimerMarkdown();
    }
    return rootBundle.loadString(path);
  }

  String _disclaimerMarkdown() {
    return [
      '# Disclaimer',
      '',
      'ClearBreath is for wellness and relaxation purposes only. It is not medical advice, diagnosis, or treatment.',
      '',
      '- Stop if you feel unwell.',
      '- Consult a qualified professional if you have medical concerns.',
      '- If you have a medical condition, are pregnant, or feel unwell, consult a qualified professional before practicing.',
      '- Stop immediately if you feel dizziness, pain, shortness of breath, or discomfort.',
      '',
      'Use breathing practices responsibly and follow technique-specific safety guidance shown in the app.',
    ].join('\\n');
  }
}
