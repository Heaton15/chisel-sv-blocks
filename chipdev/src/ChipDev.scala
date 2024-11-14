package blocks

import chisel3._
import circt.stage.ChiselStage
import common._

//The address is a two bit value whose decimal representation determines which output value to use. Append to dout the decimal representation of addr to get the output signal name dout{address decimal value}. For example, if addr=b11 then the decimal representation of addr is 3, so the output signal name is dout3.
//
//The input has an enable signal (din_en), which allows the input to be forwarded to an output when enabled. If an output is not currently being driven to, then it should be set to 0.
//Input and Output Signals
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

class SimpleRouter(dataWidth: Int) extends Module {
  val in  = IO(Input(new In(dataWidth)))
  val out = IO(Output(new Out(dataWidth)))

  out.dout :#= (0.U).asTypeOf(new Out(dataWidth).dout)

  when(in.din_en) {
    out.dout(in.addr) :#= in.din
  }

}

object Main extends App {
  println(
    ChiselStage.emitSystemVerilog(
      new SimpleRouter(32),
      firtoolOpts = FirtoolOpts.firtoolOpts,
    )
  )
}
