SHELL := $(shell which bash)
CWD := $(shell pwd)
SRC_DIR := ./src

# Source files should all exist in the src/ directory
SRCS := $(shell find $(SRC_DIR) -name "*.v" -or -name "*.sv")
UTIL := $(shell find ../util -name "*.v" -or -name "*.sv")
ALL_SRC := $(SRCS) $(UTIL)

DUT := $(shell basename $(CWD))
TOP := tb

VERILATOR := verilator

ARGS := --binary -j 0 ${ALL_SRC} -Mdir ${TOP}-out --top ${TOP} --trace

.PHONY: compile run clean

all: compile run

clean:
	@rm -rf compile.log run.log ${TOP}-out

compile:
	$(VERILATOR) $(ARGS) | tee compile.log

run: 
	${TOP}-out/V${TOP} | tee run.log

