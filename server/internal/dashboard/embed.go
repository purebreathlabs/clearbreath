package dashboard

import "embed"

//go:embed templates/*.html templates/partials/*.html
var templateFS embed.FS
