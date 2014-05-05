.PHONY: all
all:
	@echo "Usage: make run-example"

.PHONY: run-example
run-example:
	@bin/exercise-cli data/example.yml
