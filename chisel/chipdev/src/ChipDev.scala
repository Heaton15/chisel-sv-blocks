package chipdev

import chisel3._
import circt.stage.ChiselStage
import common._
import chisel3.experimental.dataview._
import chisel3.util.log2Ceil
import chisel3.util.switch
import chisel3.util.is
import chisel3.util.Cat
import chisel3.util.Reverse
import chisel3.util.Fill

// The address is a two bit value whose decimal representation determines which output value to use.
// Append to dout the decimal representation of addr to get the output signal name dout{address decimal value}. For example, if addr=b11 then the decimal representation of addr is 3, so the output signal name is dout3.

// The input has an enable signal (din_en), which allows the input to be forwarded to an output when enabled. If an output is not currently being driven to, then it should be set to 0.
// Input and Output Signals
//
//    din - Input data.
//    din_en - Enable signal for din. Forwards data from input to an output if 1, does not forward data otherwise.
//    addr - Two bit destination address. For example addr = b11 = 3 indicates din should be forwarded to output value 3 (dout3).
//    dout0 - Output 0. Corresponds to addr = b00.
//    dout1 - Output 1. Corresponds to addr = b01.
//    dout2 - Output 2. Corresponds to addr = b10.
//    dout3 - Output 3. Corresponds to addr = b11.

class In(dataWidth: Int) extends Bundle {
  val din    = UInt(dataWidth.W)
  val din_en = Bool()
  val addr   = UInt(2.W)
}

class Out(dataWidth: Int) extends Bundle {
  val dout = Vec(4, UInt(dataWidth.W))
}

class ExpectedOut(val dataWidth: Int) extends Bundle {
  val dout0 = UInt(dataWidth.W)
  val dout1 = UInt(dataWidth.W)
  val dout2 = UInt(dataWidth.W)
  val dout3 = UInt(dataWidth.W)
}

object Out {
  implicit val newView: DataView[ExpectedOut, Out] = DataView(
    vab => new Out(vab.dataWidth),
    _.dout0 -> _.dout(0),
    _.dout1 -> _.dout(1),
    _.dout2 -> _.dout(2),
    _.dout3 -> _.dout(3),
  )
}

class SimpleRouter(dataWidth: Int) extends Module {
  override def desiredName = s"SimpleRouter_$dataWidth"

  val in      = FlatIO(Input(new In(dataWidth)))
  val dout    = FlatIO(Output(new ExpectedOut(dataWidth)))
  val outView = { dout.viewAs[Out] }

  Seq.tabulate(4)(i => outView.dout(i) :#= Mux(in.din_en && in.addr === i.U, in.din, 0.U))

}

class SecondLargest(dataWidth: Int) extends Module {
  override def desiredName = s"SecondLargest_$dataWidth"

  val din  = IO(Input(UInt(dataWidth.W)))
  val dout = IO(Output(UInt(dataWidth.W)))

  val largest       = RegInit(0.U(dataWidth.W))
  val secondLargest = RegInit(0.U(dataWidth.W))

  when(din > largest && din > secondLargest) {
    largest       :#= din
    secondLargest :#= largest
  }.elsewhen(din > secondLargest) {
    secondLargest :#= din
  }

  // continuous assignment
  dout :#= secondLargest

}

//Divide an input number by a power of two and round the result to the nearest integer.
//The power of two is calculated using 2DIV_LOG2 where DIV_LOG2 is a module parameter.
//Remainders of 0.5 or greater should be rounded up to the nearest integer.
//If the output were to overflow, then the result should be saturated instead.

class RoundingDivision(divLog2: Int, outWidth: Int) extends Module {
  val in  = IO(Input(UInt((divLog2 + outWidth).W)))
  val out = IO(Output(UInt(outWidth.W)))

  out :#= 0.U.asTypeOf(out)

}

class LsbPrioArbiter(size: Int) extends RawModule {
  val req = IO(Input(UInt(size.W)))
  val gnt = IO(Output(UInt(size.W)))
  val arb = req & (~req + 1.U)
  gnt :<= arb
}

object LsbPrioArbiter {
  def apply(req: Data): UInt = {
    val arb = Module(new LsbPrioArbiter(req.getWidth))
    arb.req :<= req.asTypeOf(arb.req)
    arb.gnt
  }
}

class RoundRobinArbiter(size: Int) extends RawModule {
  // Round Robin Arbiter can be a sneaky implementation in verilog. Can we do
  // the case statement?

  val req = IO(Input(UInt(size.W)))
  val gnt = IO(Output(UInt(size.W)))
  val clk = IO(Input(Clock()))
  val rst = IO(Input(Bool()))

  val reg_ptr = withClockAndReset(clk, rst) { RegInit(UInt(log2Ceil(size).W), 0.U) }
  val req_tmp = withClockAndReset(clk, rst) { Wire(UInt(size.W))}

  reg_ptr :<= reg_ptr + 1.U

  req_tmp :<= Cat(req, req).rotateRight(reg_ptr).tail(size)
  val prio_arb = LsbPrioArbiter(req_tmp)
  gnt :<= Cat(prio_arb, prio_arb).rotateLeft(reg_ptr).head(size)

}

object Main extends App {

  ChiselStage.emitSystemVerilog(
    new SimpleRouter(32),
    firtoolOpts = FirtoolOpts.firtoolOpts,
  )

  ChiselStage.emitSystemVerilog(
    new SecondLargest(32),
    firtoolOpts = FirtoolOpts.firtoolOpts,
  )

  ChiselStage.emitSystemVerilog(
    new RoundingDivision(3, 5),
    firtoolOpts = FirtoolOpts.firtoolOpts,
  )

  ChiselStage.emitSystemVerilog(
    new RoundRobinArbiter(size = 4),
    firtoolOpts = FirtoolOpts.firtoolOpts,
  )
}
