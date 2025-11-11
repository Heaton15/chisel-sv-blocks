#!/usr/bin/env python3

import os
from pathlib import Path

import cocotb
import logging
import random
import argparse
from cocotb.handle import Immediate
from cocotb.triggers import RisingEdge, Timer
from cocotb_tools.runner import get_runner
from dataclasses import dataclass
from BitVector import BitVector


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
    sources = [proj_dir / "fa/full_adder.sv"]
    sources.append(proj_dir / "rca/ripple_carry_adder.sv")
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


async def clock(dut):
    """Create a clock pulse in the testbench"""
    dut.clk.value = 0
    while True:
        await Timer(1)
        dut.clk.value = not dut.clk.value


@cocotb.test()
async def test_ripple_carry_adder(dut):
    logger = logging.getLogger("test")
    SAMPLES = 1 << 10
    N = 4
    a = [
        BitVector(intVal=random.randint(0, (1 << N) - 1), size=N)
        for _ in range(SAMPLES)
    ]
    b = [
        BitVector(intVal=random.randint(0, (1 << N) - 1), size=N)
        for _ in range(SAMPLES)
    ]
    out = [
        BitVector(intVal=a[i].int_val() + b[i].int_val(), size=N + 1)
        for i in range(SAMPLES)
    ]

    for i in range(SAMPLES):
        dut.a.value = a[i].int_val()
        dut.b.value = b[i].int_val()
        await Timer(1, unit="ns")
        logger.info(
            f"a:{a[i]}, b:{b[i]}, z: {out[i]} ({int(a[i])} + {int(b[i])} = {int(out[i])})"
        )
        result = BitVector(intVal=dut.cout.value, size=1) + BitVector(
            intVal=dut.z.value, size=N
        )
        assert result.int_val() == out[i].int_val()
        await Timer(1, unit="ns")


if __name__ == "__main__":
    testbench(BlockCli.build_parser().module)
