SHELL := $(shell which bash)
CWD := $(shell pwd)
SRC_DIR := ./src

# Source files should all exist in the src/ directory
SRCS := $(shell find $(SRC_DIR) -name "*.v" -or -name "*.sv")

DUT := $(shell basename $(CWD))
TOP := tb

VERILATOR := verilator

ARGS := --binary -j 0 ${SRCS} -Mdir ${TOP}-out --top ${TOP}

.PHONY: compile run

all: compile run

compile:
	$(VERILATOR) $(ARGS) | tee compile.log

run: 
	${TOP}-out/V${TOP} | tee run.log

