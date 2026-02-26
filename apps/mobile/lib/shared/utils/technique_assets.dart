String? techniqueImageAsset(String techniqueId) {
  return switch (techniqueId) {
    'box' => 'assets/images/box-breathing.png',
    'four_seven_eight' => 'assets/images/addition.png',
    'anulom_vilom' => 'assets/images/anulom-vilom.png',
    'ujjayi' => 'assets/images/ujjayi.png',
    'bhramari' => 'assets/images/bhramari.png',
    'hrv_resonance' => 'assets/images/hrv.png',
    'ultra_slow' => 'assets/images/addtional-3.png',
    'kapalbhati' => 'assets/images/kapaalbhati.png',
    'bhastrika' => 'assets/images/bhastrika.png',
    _ => null,
  };
}
