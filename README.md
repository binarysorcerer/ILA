# Integrated Logic Analyzer using FPGA

This repository contains the Verilog source code for a low-cost, single-channel Integrated Logic Analyzer (ILA). The system uses an FPGA for high-speed signal capture and a UART interface to transmit the captured data to a host PC for real-time visualization.

This project was developed as a practical, affordable, and user-friendly logic analysis solution for academia, hobbyists, and small-scale industry applications.

---

## Key Features
- **Maximum Sampling Rate:** 25 MHz  
- **Buffer Depth:** 1 KB (8192 samples)  
- **Hardware:** FPGA-based signal acquisition and buffering (Developed on Altera DE2)  
- **Communication:** UART serial interface for data transmission  
- **Software:** Python-based GUI for waveform visualization and analysis  

---

## System Architecture

The logic analyzer consists of two main components that operate sequentially:

1. **FPGA Hardware (Signal Capture)**  
   Programmed in Verilog, the FPGA captures digital signals in real time. It samples the input, detects a trigger, and stores the data in an internal 1 KB RAM block.

2. **PC Software (Visualization)**  
   A Python script on the host computer listens on the serial port. After the FPGA has captured the data, it transmits it over UART to the Python application, which then processes and plots the digital waveform.

---

## How It Works

The system follows a sequential capture-transmit loop to ensure no data loss at high speeds:

1. **Wait for Trigger:** The FPGA waits for a start command.  
2. **Capture Phase:** Samples the digital input at 25 MHz and writes data to `two_port_ram` until the buffer is full.  
3. **Halt & Transmit Phase:** Stops sampling and reads data from RAM to transmit over UART to the PC.  
4. **Repeat:** The process can be re-triggered for the next capture.  

---

## Project File Structure

- **`AssemblingB.v`** – Top-level module integrating all components. Manages the state machine and controls data flow.  
- **`two_port_ram.v`** – Implements a dual-port 1024×8 RAM for buffering captured signal data.  
- **`uart_tx.v`** – UART transmitter for serializing and sending data to the PC.  
- **`uart_rx.v`** – UART receiver for accepting start/reset commands from the PC.  
- **`python_gui.py`** – Python-based GUI for receiving and visualizing waveform data.  

---

## Usage

1. **Program FPGA**  
   Synthesize and program the Verilog files onto a compatible FPGA board (e.g., Altera DE2). Verify pin assignments for the signal input and UART.

2. **Connect Hardware**  
   Use a USB-to-serial converter to connect the FPGA's UART pins to your PC.

3. **Run PC Software**  
   Execute the Python visualization script. Set the correct COM port and baud rate (`115200`).

4. **Capture**  
   Apply a digital signal to the FPGA input pin, trigger the capture, and view the waveform in the Python GUI.

---

## Acknowledgements

The UART (TX and RX) Verilog modules are based on the open-source designs from [nandland.com](https://nandland.com). Their resources are highly recommended for learning digital design.

---
