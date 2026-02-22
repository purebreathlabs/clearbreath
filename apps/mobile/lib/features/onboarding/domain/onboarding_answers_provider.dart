import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_answers.dart';
import 'onboarding_gate.dart';

final onboardingAnswersProvider = FutureProvider<OnboardingAnswers>((ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  final answers = await repository.readAnswers();
  return answers ?? OnboardingAnswers.defaults();
});
