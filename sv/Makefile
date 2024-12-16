SHELL := $(shell which bash)

SRC_DIRS := $(shell find . -type d -depth 1)

all: compile-all run-all

compile-all:
	@for dir in $(SRC_DIRS); do \
		$(MAKE) -C $$dir compile; \
	done

run-all:
	@for dir in $(SRC_DIRS); do \
		$(MAKE) -C $$dir run; \
	done
