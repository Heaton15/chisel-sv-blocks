package common 

object FirtoolOpts {
  def firtoolOpts = Array(
    "-disable-all-randomization",
    "-strip-debug-info",
    "--disable-opt",
    "--split-verilog",
    "-o",
    "gen-collateral",
  )
}
