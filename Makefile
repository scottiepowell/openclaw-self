.PHONY: doctor validate diff backup sync

doctor:
	bash scripts/doctor.sh

validate:
	bash scripts/validate-config.sh

diff:
	git diff -- config agents skills docs scripts AGENTS.md README.md Makefile

backup:
	bash scripts/backup-openclaw.sh

sync:
	bash scripts/sync-openclaw-config.sh
