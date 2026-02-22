export type SeoPageKind = 'technique' | 'hub';

export type SeoPage = {
  slug: string;
  kind: SeoPageKind;
  title: string;
  description: string;
  h1: string;
  techniqueId?: string;
};

export const seoPages: SeoPage[] = [
  {
    slug: 'hrv-resonance-breathing',
    kind: 'technique',
    techniqueId: 'hrv_resonance',
    title: 'HRV Resonance Breathing — ClearBreath',
    description:
      'A steady, even breathing pattern commonly used in HRV training protocols.',
    h1: 'HRV resonance breathing',
  },
  {
    slug: 'ultra-slow-breathing',
    kind: 'technique',
    techniqueId: 'ultra_slow',
    title: 'Ultra-Slow Breathing — ClearBreath',
    description:
      'Very slow breathing for deep calm and control. Practice gently and safely.',
    h1: 'Ultra-slow breathing',
  },
  {
    slug: 'diaphragmatic-breathing',
    kind: 'technique',
    techniqueId: 'diaphragmatic',
    title: 'Diaphragmatic Breathing — ClearBreath',
    description: 'Gentle belly breathing to calm and steady.',
    h1: 'Diaphragmatic breathing',
  },
  {
    slug: 'box-breathing-timer',
    kind: 'technique',
    techniqueId: 'box',
    title: 'Box Breathing Timer — ClearBreath',
    description: 'A balanced four-part breath for focus and control.',
    h1: 'Box breathing timer',
  },
  {
    slug: '478-breathing-timer',
    kind: 'technique',
    techniqueId: 'four_seven_eight',
    title: '4-7-8 Breathing Timer — ClearBreath',
    description: 'A classic calming pattern with a long exhale.',
    h1: '4-7-8 breathing timer',
  },
  {
    slug: 'yogic-three-part-breathing',
    kind: 'technique',
    techniqueId: 'yogic_three_part',
    title: 'Yogic Three-Part Breathing — ClearBreath',
    description:
      'A fuller breath that gently expands belly, ribs, and upper chest.',
    h1: 'Yogic three-part breathing',
  },
  {
    slug: 'anulom-vilom-timer',
    kind: 'technique',
    techniqueId: 'anulom_vilom',
    title: 'Anulom Vilom Timer — ClearBreath',
    description:
      'Alternate nostril breathing for balance and steadiness with clear pacing.',
    h1: 'Anulom Vilom timer',
  },
  {
    slug: 'ujjayi-breathing',
    kind: 'technique',
    techniqueId: 'ujjayi',
    title: 'Ujjayi Breathing — ClearBreath',
    description: 'A slow, steady breath with gentle throat control.',
    h1: 'Ujjayi breathing',
  },
  {
    slug: 'bhramari-bee-breathing',
    kind: 'technique',
    techniqueId: 'bhramari',
    title: 'Bhramari (Bee Breath) — ClearBreath',
    description: 'A soothing hum on the exhale for relaxation.',
    h1: 'Bhramari (bee breath)',
  },
  {
    slug: 'kapalbhati-counter',
    kind: 'technique',
    techniqueId: 'kapalbhati',
    title: 'Kapalbhati Counter — ClearBreath',
    description:
      'A rapid practice paced in rounds with rests. Use ClearBreath for safe guidance.',
    h1: 'Kapalbhati counter',
  },
  {
    slug: 'bhastrika-breathing',
    kind: 'technique',
    techniqueId: 'bhastrika',
    title: 'Bhastrika Breathing — ClearBreath',
    description:
      'A strong, rhythmic breath paced in rounds with rests. Practice gently and safely.',
    h1: 'Bhastrika breathing',
  },
  {
    slug: 'breathing-for-sleep',
    kind: 'hub',
    title: 'Breathing for Sleep — ClearBreath',
    description:
      'Simple breathing techniques you can use to wind down and settle before bed.',
    h1: 'Breathing for sleep',
  },
];

