package blocks

import chisel3._
import circt.stage.ChiselStage

class Top extends Module {

}

object Main extends App {
  // These lines generate the Verilog output
  println(
    ChiselStage.emitSystemVerilog(
      new Top(),
      firtoolOpts = blocks.firtoolOpts
    )
  )
}
