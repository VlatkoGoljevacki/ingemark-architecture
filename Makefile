.PHONY: serve help

help:
	@echo "Architecture Index Commands"
	@echo ""
	@echo "  make serve   - Serve the index site locally at http://localhost:3000"
	@echo ""

serve:
	docker compose up serve
