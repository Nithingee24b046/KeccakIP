# SHA-3 Hardware Accelerator

A high-performance hardware implementation of the **SHA-3 (Keccak)** cryptographic hash algorithm in Verilog. This project focuses on designing a pipelined and synthesizable SHA-3 accelerator suitable for FPGA and ASIC implementations, with future extensions toward post-quantum cryptographic accelerators such as **CRYSTALS-Kyber** and **CRYSTALS-Dilithium**.

---

## Features

- Fully synthesizable Verilog implementation
- Implements the SHA-3 (Keccak-f[1600]) permutation
- FPGA and ASIC friendly design
- Designed for high throughput and low latency
- Easily extensible for post-quantum cryptographic applications

---

## SHA-3 Overview

SHA-3 is the latest member of the Secure Hash Algorithm family standardized by **NIST** in **FIPS 202**. Unlike SHA-1 and SHA-2, SHA-3 is based on the **Keccak sponge construction**, which consists of three main stages:

1. **Absorbing** input blocks into the internal state.
2. Applying the **Keccak-f[1600] permutation**.
3. **Squeezing** the required number of output bits.

The Keccak-f permutation consists of the following five transformations performed every round:

- **Theta (θ)**
- **Rho (ρ)**
- **Pi (π)**
- **Chi (χ)**
- **Iota (ι)**

The permutation is executed for **24 rounds**.

---

## Supported Algorithms

Current implementation:

- SHA3-224
- SHA3-256
- SHA3-384
- SHA3-512

Future extensions:

- SHAKE128
- SHAKE256

---

## Future Work

This repository is intended to evolve into a complete hardware cryptography library implementing components required for modern post-quantum cryptography.

Planned implementations include:

- CRYSTALS-Kyber
  - Number Theoretic Transform (NTT)
  - Inverse NTT
  - Modular arithmetic
  - Polynomial multiplication
  - Keccak-based PRF
- CRYSTALS-Dilithium
  - Polynomial arithmetic
  - Sampling modules
  - Signing and verification pipeline
- Shared SHAKE accelerator
- Optimized Keccak datapath
- FPGA benchmarking and ASIC synthesis

---

## Design Goals

- High throughput
- Low hardware area
- Pipeline-friendly implementation
- Reusable cryptographic building blocks
