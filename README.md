# LPC1768 PIN-Lock System

This project implements a secure, PIN-based access control system on the LPC1768 ARM Cortex-M3 microcontroller using pure ARM Assembly. Designed for lightweight performance and full hardware-level control, the system verifies user input, decrypts password, and simulates GPIO-based LED feedback, without relying on external libraries.

## Overview

The system accepts a 4-digit user PIN and compares it with a list of valid stored PINs. Upon successful authentication:

- A decrypted password is written to memory.
- A success message is stored in memory.
- A GPIO-based LED blinking sequence is simulated using Ports 1 and 2.

If the entered PIN is incorrect:
- Access is silently denied.
- The user has 3 attempts, with a delay enforced between each attempt.
- After 3 failed attempts, the system locks further input.

## Features

- Supports multiple valid PINs
- Displays a success message in memory upon correct entry
- Simulates LED blinking via GPIO control (FIO1 and FIO2 registers)
- 3-attempt limit with timeout to prevent brute-force
- XOR-based password encryption and decryption
- Fully written in ARM Assembly using Keil µVision IDE
- Minimal memory usage and register-level implementation



## Project Structure
├── Ekansh1.s # Main Assembly Source
├── startup_LPC17xx.s # Startup code
├── FinalProject.uvproj # Keil Project File
├── README.md # This file
├── .gitignore # Ignored build files
├── /videos/ # Demo simulation videos
└── /screenshots/ # Output and code snapshots 
└──  Project Report 


## Technologies Used

- ARM Cortex-M3 (LPC1768)
- Keil µVision4 IDE
- ARM Assembly Language
- Memory-mapped I/O (GPIO registers)

## Notes

- PINs are 4 ASCII characters, null-terminated
- Decrypted password is displayed in memory after validation
- LEDs are simulated via GPIO (FIO1DIR/FIO1SET/CLR and FIO2DIR/SET/CLR)
- Assembly-only, no C or high-level libraries used

## Author

Ekansh  
Electrical and Electronics Engineering  
NITK Surathkal  
IET ROVISP SMP Project


