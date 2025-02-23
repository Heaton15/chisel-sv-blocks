SHELL := $(shell which bash)
VFILES := $(shell find . -name "*.sv" -maxdepth 1)
TARGETS := $(foreach file, $(VFILES), $(basename $(notdir ${file})))


HELP_LINES := "" \
	"Available Targets" \
	$(foreach target, $(TARGETS), " - $(target)") \
	"" \
	"Other targets:" \
	"help - display this help information" \
	""

default:

$(TARGETS):
	@echo "Building target: $@"

help:
	@for line in $(HELP_LINES); do echo "$$line"; done

