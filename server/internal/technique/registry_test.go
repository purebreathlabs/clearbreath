package technique

import "testing"

func TestLoadRegistry(t *testing.T) {
	r, err := Load("../../registry/techniques.json")
	if err != nil {
		t.Fatalf("load: %v", err)
	}

	if _, ok := r.Preset("hrv_resonance", "beginner"); !ok {
		t.Fatalf("expected preset")
	}
	if _, ok := r.Preset("unknown", "beginner"); ok {
		t.Fatalf("unexpected preset")
	}
}
