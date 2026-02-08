# Synchronous FIFO Verification Using UVM

This repository contains a **Universal Verification Methodology (UVM)** based verification environment for a **synchronous FIFO** hardware design. It uses constrained-random stimulus, functional coverage, assertions, and a **C++ reference model** in the scoreboard to validate the FIFO’s behavior against expected data. The verification ensures that the FIFO functions correctly under a wide range of scenarios including simultaneous read/write operations, full/empty conditions, overflow and underflow cases.

---

## 📌 Project Overview

A synchronous FIFO (First-In-First-Out) buffer temporarily stores data in a queue and ensures that the data read out is in the same order as it was written. This structure is fundamental in digital designs where decoupling of producer and consumer logic is required.

**Verification Goals:**
- Ensure **FIFO ordering** (first in, first out)
- Validate **status flags** such as full and empty
- Confirm correct behavior for **simultaneous operations**
- Detect **underflow/overflow** conditions
- Achieve **functional coverage closure** across corner cases:contentReference[oaicite:0]{index=0}

---

## 🧠 Why UVM & C++ Reference Model?

**UVM (Universal Verification Methodology)** provides:
- Modular, reusable verification components
- Constrained random stimulus generation
- Functional coverage collection
- Self-checking capabilities through a scoreboarding mechanism

The **C++ reference model** acts as a trusted golden predictor inside the scoreboard. It enables precise comparison between the expected output (predicted by the C++ model) and the actual output from the DUT, ensuring robust functional verification beyond simple RTL simulation. This is a common practice in advanced verification environments to model expected behavior outside of the DUT’s logic domain.:contentReference[oaicite:1]{index=1}

---

## 📁 Repository Structure

Synchronous-FIFO-Verification-by-UVM/
├── design/ # FIFO RTL source
│ └── fifo.sv
│
├── verification/ # UVM environment
│ ├── env/ # Environment components (agent, scoreboard, monitor, driver)
│ ├── sequences/ # UVM transaction sequences
│ ├── models/ # C++ reference model & DPI interfaces
│ ├── tests/ # UVM test cases
│ ├── coverage/ # Coverage definitions
│ └── uvm_pkg.sv # UVM base package and imports
│
├── sim/ # Simulation and build scripts
├── Makefile # Automation for compile and run
└── README.md # Project documentation



---

## 🧪 UVM Verification Components

| Component | Responsibility |
|-----------|----------------|
| **Driver** | Drives transactions into the FIFO from sequences |
| **Monitor** | Observes DUT interface and sends transactions to scoreboard & coverage |
| **Scoreboard** | Compares DUT results with predictions from the C++ reference model |
| **Sequences** | Provide constrained-random and directed stimuli |
| **Functional Coverage** | Tracks exercised behavior and corner cases |

The scoreboard typically uses a *transaction queue* and the reference model to compare DUT output with expected output, reporting mismatches. A scoreboard design often receives transactions from the monitor via analysis ports and compares those with expected values provided by the reference model.:contentReference[oaicite:2]{index=2}

---

## 🚀 How to Run the Verification

### Prerequisites

1. **Simulator with UVM support**, such as QuestaSim, VCS, or Xcelium.
2. **SystemVerilog with DPI-C support** to connect the C++ model for the scoreboard.

### Running the Tests

1. Clone the repository:
   ```bash
   git clone https://github.com/sunnysudheer393/Synchronous-FIFO-Verification-by-UVM.git
   cd Synchronous-FIFO-Verification-by-UVM


vlog +acc uvm_pkg.sv design/fifo.sv verification/**/*.sv
vsim -c -do "run -all; quit"


