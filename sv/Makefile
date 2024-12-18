SHELL := $(shell which bash)

SRC_DIRS := $(shell find . -type d -depth 1)

SRC_V := $(shell find . -name "*.v" -or -name "*.sv")

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
	@for file in $(SRC_V); do \
		echo $(shell pwd)/$$file >> $@; \
	done
