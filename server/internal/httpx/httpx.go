package httpx

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type errorResponse struct {
	Error     string `json:"error"`
	Code      string `json:"code,omitempty"`
	RequestID string `json:"request_id,omitempty"`
}

func WriteJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func WriteError(w http.ResponseWriter, status int, code string, message string, requestID string) {
	WriteJSON(w, status, errorResponse{
		Error:     message,
		Code:      code,
		RequestID: requestID,
	})
}

func DecodeJSON(w http.ResponseWriter, r *http.Request, maxBytes int64, dst any) error {
	r.Body = http.MaxBytesReader(w, r.Body, maxBytes)
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()

	if err := dec.Decode(dst); err != nil {
		if err == io.EOF {
			return fmt.Errorf("empty body: %w", err)
		}
		return err
	}

	var extra any
	if err := dec.Decode(&extra); err != io.EOF {
		if err == nil {
			return fmt.Errorf("unexpected trailing data")
		}
		return err
	}

	return nil
}
