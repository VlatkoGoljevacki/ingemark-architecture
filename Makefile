.PHONY: start export adr help

PROJECT ?= Pace

help:
	@echo "Architecture Repository Commands"
	@echo ""
	@echo "  make start              - Start LikeC4 dev server"
	@echo "  make export PROJECT=X   - Export diagrams for project X"
	@echo "  make adr PROJECT=X TITLE=Y - Create new ADR"
	@echo ""

start:
	docker compose up likec4

export:
	@echo "Exporting diagrams for $(PROJECT)..."
	docker compose run --rm -T likec4 export png \
		--output ./$(PROJECT)/exports/ \
		./$(PROJECT)/architecture/

adr:
	@if [ -z "$(TITLE)" ]; then echo "Usage: make adr PROJECT=Pace TITLE=my-decision"; exit 1; fi
	@NEXT=$$(ls -1 $(PROJECT)/docs/adr/*.md 2>/dev/null | wc -l | xargs -I{} expr {} + 1); \
	PADDED=$$(printf "%04d" $$NEXT); \
	FILE="$(PROJECT)/docs/adr/$${PADDED}-$(TITLE).md"; \
	echo "# ADR-$${PADDED}: $(TITLE)\n\n## Status\nProposed\n\n## Context\n[Why is this decision needed?]\n\n## Decision\n[What was decided?]\n\n## Consequences\n[What are the implications?]\n\n## Affected Elements\n<!-- LikeC4 elements affected by this decision -->\n- \`element.path\`\n\n## Related\n- [Diagram: View Name](../exports/view-name.png)" > $$FILE; \
	echo "Created: $$FILE"
