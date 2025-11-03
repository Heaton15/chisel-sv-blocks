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
    sources = [proj_dir / "prio_arbiter_lsb_to_msb.sv"]
    sources.append(proj_dir / "prio_arbiter_msb_to_lsb.sv")
    sources.append(proj_dir / "round_robin_arbiter.sv")
    sources.append(proj_dir / "sync_fifo.sv")
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


async def clock(dut):
    dut.clk.value = 0
    while True:
        await Timer(1)
        dut.clk.value = not dut.clk.value


def compute_prio(curr_prio: int) -> int:
    if curr_prio == 3:
        return 0
    else:
        return curr_prio + 1


def expected_rr_output(prio: int, req: int, size: int) -> int:
    bv = BitVector(size=4, intVal=int(req))
    bv >> prio
    bv = BitVector(size=4, intVal=bv.int_val() & (~bv.int_val() + 1))
    bv << prio
    return bv.int_val()


@cocotb.test()
async def test_round_robin_arbiter(dut):
    dut.rst.value = 1
    logger = logging.getLogger("test")
    cocotb.start_soon(clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    prio = 0
    for _ in range(1000):
        await RisingEdge(dut.clk)
        rand_req = random.randrange(1, (1 << 4))
        dut.req.value = rand_req
        logger.info(f"req: {dut.req.value} gnt: {dut.gnt.value}")
        assert dut.gnt.value == expected_rr_output(prio, dut.req.value, 4)
        prio = compute_prio(prio)


async def sync_in(dut, gold_data: list[int]):
    cnt = 0
    dut.wr_en.value = 1
    dut.data_i.value = gold_data[0]

    while True:
        if not dut.full.value:
            dut.data_i.value = gold_data[cnt]
            cnt += 1
        if cnt == 1000:
            return
        await RisingEdge(dut.clk)


async def sync_out(dut) -> list[int]:
    cnt = 0
    rx = []
    dut.rd_en.value = 1

    while True:
        if not dut.empty.value:
            await Timer(1)
            rx.append(int(dut.data_o.value))
            cnt += 1
        if cnt == 1000:
            return rx
        await RisingEdge(dut.clk)


@cocotb.test()
async def test_sync_fifo(dut):
    dut.rst.value = 1
    logger = logging.getLogger("test")
    gold = [random.randint(0, 1 << 16) for _ in range(1000)]
    cocotb.start_soon(clock(dut))
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    cocotb.start_soon(sync_in(dut, gold))
    rx = await cocotb.start_soon(sync_out(dut))

    assert len(gold) == len(rx)
    for g, rec in zip(gold, rx):
        logger.info(f"gold: {hex(g)} rec: {hex(rec)}")
        assert hex(g) == hex(rec)


if __name__ == "__main__":
    testbench(BlockCli.build_parser().module)
