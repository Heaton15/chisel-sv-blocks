# chisel-sv-blocks

# Blocks
- sync fifo [x]
- async fifo [x]
- CDC design [x]
- round-robin arbiter [x]
- re-order buffer
- branch predictor
- weighted arbiter
- glitch-free clock mux
- SPI controller
- I2C controller
- JTAG TAP Controller
- grey code counter
- edge detector
- parallel-in, serial-out SR
- serial-in, parallel-out SR
- palindrome detector
- grey code to binary
- multi-bit FIFO
- 2-read-1-write (2W1R) Register File
- bubble sort

# Util 
- util/g2b.sv
- util/b2g.sv

# Clock Domain Crossings

# Synchronizers

# Gray / Binary Encoders
## Gray To Binary
1. MSB of Gray and Binary are the same g[MSB] = b[MSB]
1. The binary bits are then g[i] ^ b[i+1]

## Binary to Grey
1. MSB of Gray and Binary are the same g[MSB] = b[MSB]
1. The gray bits are then the xor of the binary b[i] ^ b[i+1]
