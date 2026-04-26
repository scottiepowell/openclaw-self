.PHONY: doctor validate validate-all diff review backup sync

doctor:
	bash scripts/doctor.sh

validate:
	bash scripts/validate-config.sh

validate-all:
	bash -n scripts/*.sh
	bash scripts/validate-config.sh
	bash scripts/review-diff.sh
	bash scripts/doctor.sh

diff:
	git diff -- config agents skills docs scripts AGENTS.md README.md Makefile

review:
	bash scripts/review-diff.sh

backup:
	bash scripts/backup-openclaw.sh

sync:
	bash scripts/sync-openclaw-config.sh
