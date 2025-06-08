# DV-Interview-Prep-Guide

This repository contains a collection of SystemVerilog examples, conceptual notes, and commonly asked questions, compiled to aid in Design Verification (DV) interview preparation. These materials are based on my own interview experiences and resources found online.

My aim is to provide a conceptual overview and serve as a quick revision guide or a starting point for those preparing for similar roles. I recommend studying the materials in the order presented below for a structured learning path.

**🛠️ Note:**
Most of the content is written in pseudo-code style and is **not simulation tested**. Please treat this as reference material – it's intended to act as quick revision material for interviews or as a starting point, not a production-ready solution. I highly recommend doing your own testing and validation. As a new college graduate, these materials focus on foundational concepts rather than highly complex problems.

## Resource Guide

Here's a breakdown of the resources available in this repository, organized to follow a recommended study order:

### 1. SystemVerilog Constraints

This section covers various aspects of SystemVerilog constraints, a crucial topic for verification engineers.

* **File:** [`constraints.sv`](constraints.sv)
* **Description:** This file contains SystemVerilog examples and conceptual notes related to constrained random verification. It's an excellent starting point for understanding how to define and apply constraints to generate valid test scenarios.

### 2. Protocol Sample Codes

Explore implementations and conceptual overviews of common industry protocols.

* **Directory:** [`00_Protocol/`](00_Protocol/)
    * **File:** [`00_Protocol/AXI4_protocol.sv`](00_Protocol/AXI4_protocol.sv)
        * **Description:** A sample implementation and notes for the AXI4 protocol, commonly used in SoC design.
    * **File:** [`00_Protocol/apb_protocol.sv`](00_Protocol/apb_protocol.sv)
        * **Description:** Provides an overview and example code for the Advanced Peripheral Bus (APB) protocol, often used for low-bandwidth peripheral communication.
    * **File:** [`00_Protocol/i2c_protocol.sv`](00_Protocol/i2c_protocol.sv)
        * **Description:** Contains SystemVerilog code related to the I2C (Inter-Integrated Circuit) serial communication protocol.
    * **File:** [`00_Protocol/protocol.sv`](00_Protocol/protocol.sv)
        * **Description:** General SystemVerilog examples related to protocol modeling and implementation.

### 3. OOP Sample Examples in SystemVerilog

Delve into Object-Oriented Programming (OOP) concepts as applied in SystemVerilog, essential for building robust verification environments.

* **Directory:** [`02_OOP/`](02_OOP/)
    * **File:** [`02_OOP/OOP.sv`](02_OOP/OOP.sv)
        * **Description:** Core SystemVerilog OOP examples illustrating classes, objects, inheritance, polymorphism, and other fundamental OOP principles.
    * **File:** [`02_OOP/OOP_tutorial.sv`](02_OOP/OOP_tutorial.sv)
        * **Description:** A more tutorial-focused set of OOP examples, guiding through concepts with practical code.
    * **File:** [`02_OOP/OOP_questions.sv`](02_OOP/OOP_questions.sv)
        * **Description:** Sample SystemVerilog code addressing common OOP-related questions encountered in DV interviews.

### 4. Theory Questions in DV Interview

This section compiles theoretical questions commonly asked in Design Verification interviews.

* **File:** [`important_questions.sv`](important_questions.sv)
* **Description:** A collection of conceptual and theoretical questions relevant to Design Verification, covering a broad range of topics you might encounter in an interview. While the extension is `.sv`, the content is primarily text-based questions.

### 5. SV Design Questions

Focuses on SystemVerilog design aspects and design verification scenarios.

* **File:** [`SV_design.sv`](SV_design.sv)
* **Description:** Contains SystemVerilog design-related questions and potential approaches to solve them, focusing on how SystemVerilog can be utilized for design and verification.

### 6. Multi-Master Multi-Slave Sample Code

A practical project example demonstrating a more complex verification environment setup.

* **Directory:** [`01_Projects/Multi-Master_Multi-Slave/`](01_Projects/Multi-Master_Multi-Slave/)
* **Description:** This directory contains a sample UVM-based verification environment for a multi-master multi-slave system. It includes components like:
    * `interconnect_new.sv`: The DUT (Design Under Test) for the interconnect.
    * `master/`: Contains agent, driver, monitor, and environment for the master.
    * `slave/`: Contains agent, driver, monitor, and environment for the slave.
    * `scoreboard_compare.sv`, `scoreboard.sv`: For data integrity checking.
    * `seqeunce.sv`, `sequencer.sv`: UVM sequences and sequencers.
    * `testbench.sv`, `test.sv`: Top-level testbench and test cases.
    * `top_env.sv`, `transaction.sv`, `virtual_sequencer.sv`, `virtual_sequence.sv`: Other essential UVM components for this complex setup.

---
