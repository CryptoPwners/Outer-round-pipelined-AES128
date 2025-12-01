# Outer-round Pipelined AES-128

Repository for project work done in partial fulfilment of the requirements
of the course [CS666: Hardware Security for Internet-of-Things](https://www.cse.iitk.ac.in/pages/CS666.html)
offered at [IIT Kanpur](https://www.cse.iitk.ac.in) in Fall 2026 under the
guidance of [Prof. Urbi Chatterjee](https://www.cse.iitk.ac.in/users/urbic).

## Description

The Advanced Encryption Standard (AES) is a symmetric block cipher
standardised by the National Institute of Standards and Technology (NIST)
in 2001 based on the Rijndael cipher designed by Joan Daemen and Vincent
Rijmen. The specification, detailed in [NIST FIPS 197](https://doi.org/10.6028/NIST.FIPS.197-upd1),
defines AES as operating on 128-bit blocks with key sizes of 128, 192, or
256 bits, employing a substitution-permutation network structure with 10,
12, or 14 rounds, respectively.

The AES cipher algorithm is widely used for encryption due not just to
its proven security against a wide range of attacks, but also to its
simplicity, ease of implementation, and throughput. The iterative structure
of the AES cipher algorithm makes it amenable to highly performant
pipelined hardware implementations.

To achieve a comfortable balance between latency and throughput, we
use an outer-round pipelining strategy for our design of a hardware module
for the AES cipher algorithm. The design is written in Verilog and is
implemented and verified on a PYNQ-Z2 FPGA development board using the
AMD Vivado™ Design Suite.

## Building the Project

You will need the [AMD Vivado™ Design Suite](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html)
to build the project.

To build, simply add all files under the [`src`](src)
directory as design sources and those under the [`test`](test) directory
as simulation sources to a new Vivado project. Then, add the constraints
file [`constraints/pynq_z2.xdc`](constraints/pynq_z2.xdc).

If you merely wish to simulate the design and do not want to implement it
on a Xilinx board, any conformant simulator should work. The Verilog
source is portable; as no Xilinx-specific primitives are instantiated,
you should be able to implement the design with minimal change on other
platforms as well (or even in ASIC). However, in both cases, the
given constraints file should be omitted.

## Results

The design was implemented on a PYNQ-Z2 FPGA development board interfaced with
the Zynq-7000 Processing System at a clock frequency of 200.000 MHz. The
implemented design had a throughput of 25.6 Gbps with an initial latency of
11 clock cycles and utilised 2528 logic slices with an LUT count of 9808 and
an FF count of 2688.
