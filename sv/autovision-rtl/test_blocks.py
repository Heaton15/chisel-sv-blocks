#!/usr/bin/env python3

import os
from pathlib import Path

import cocotb
import logging
import random
import argparse
from cocotb.triggers import Timer
from cocotb_tools.runner import get_runner
from dataclasses import dataclass


@dataclass
class BlockCli:
    module: str = "DEFAULT"

    @classmethod
    def build_parser(cls):
        parser = argparse.ArgumentParser()
        parser.add_argument("-m", "--module", type=str)
        args = parser.parse_args()
        return BlockCli(module=args.module)


def testbench(top_module: str):
    build_args = []

    sim = os.getenv("SIM", "verilator")
    proj_dir = Path(__file__).parent
    sources = [proj_dir / "prio_arbiter_lsb_to_msb.sv"]
    sources.append(proj_dir / "prio_arbiter_msb_to_lsb.sv")
    defines = {}

    runner = get_runner(sim)
    runner.build(
        sources=sources, hdl_toplevel=top_module, build_args=build_args, defines=defines
    )

    runner.test(
        hdl_toplevel=top_module,
        test_module="test_blocks",
        testcase=f"test_{top_module}",
    )


@cocotb.test()
async def test_prio_arbiter_lsb_to_msb(dut):
    logger = logging.getLogger("test")
    for _ in range(10000):
        await Timer(1)
        rand_req = random.randrange(0, (1 << 4) - 1)
        expected = rand_req & -rand_req
        dut.req.value = rand_req
        await Timer(1)
        logger.info(
            f"req: {rand_req:04b} : expected: {bin(expected)} : actual {dut.gnt.value}"
        )
        assert dut.gnt.value == expected


@cocotb.test()
async def test_prio_arbiter_msb_to_lsb(dut):
    logger = logging.getLogger("test")
    for _ in range(10000):
        await Timer(1)
        rand_req = random.randrange(1, (1 << 4))

        # The length of rand_req is the MSB bit anyways, so that makes this easy.
        expected = 1 << (rand_req.bit_length() - 1) if rand_req > 0 else 0

        dut.req.value = rand_req
        await Timer(1)
        logger.info(
            f"req: {rand_req:04b} : expected: {bin(expected)} : actual {dut.gnt.value}"
        )
        assert int(dut.gnt.value) == expected


if __name__ == "__main__":
    testbench(BlockCli.build_parser().module)
