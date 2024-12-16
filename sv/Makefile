SHELL := $(shell which bash)

SRC_DIRS := $(shell find . -type d -depth 1)

UTIL := $(shell find ./util -name "*.v" -or -name "*.sv")
SRC_V := $(shell find . -name "*.v" -or -name "*.sv")

ALL_SRC := $(SRC_V) $(UTIL)


.PHONY: vmode.f

all: vmode.f compile-all run-all


compile-all:
	@for dir in $(SRC_DIRS); do \
		$(MAKE) -C $$dir compile; \
	done

run-all:
	@for dir in $(SRC_DIRS); do \
		$(MAKE) -C $$dir run; \
	done

FILE := vmode.f
vmode.f:
	@if [[ -f $(FILE) ]]; then \
		rm $(FILE); \
	fi
	@$(foreach file, $(ALL_SRC), echo $(file) >> $@;)
