# Warfarin Dosing Control System

## Project Overview

This project investigates closed-loop control strategies for anticoagulant therapy using computational modeling and simulation.

The objective is to evaluate the performance of different control approaches for Warfarin dosing, with particular attention to maintaining the International Normalized Ratio (INR) within the therapeutic range.

The project was developed as part of the **Control of Biological Systems** course.

## Objectives

The main objectives of this project are:

* Develop and simulate closed-loop control strategies for Warfarin dosing.
* Investigate the performance of PID and Model Predictive Control (MPC).
* Analyze the response of pharmacokinetic and pharmacodynamic models.
* Evaluate INR regulation within the therapeutic range of 2.0–3.0.
* Assess controller performance across a simulated patient population.

## Methodology

### Pharmacokinetic and Pharmacodynamic Modeling

The project uses pharmacokinetic and pharmacodynamic (PK/PD) modeling to describe the relationship between Warfarin administration and INR response.

### Control Strategies

Two control approaches were investigated:

* **PID Control:** A feedback control strategy based on proportional, integral, and derivative actions.
* **Model Predictive Control (MPC):** An optimization-based strategy that predicts future system behavior to determine control actions.

### Simulation and Evaluation

The control strategies were implemented and evaluated using **MATLAB and Simulink**.

The analysis considered:

* A therapeutic INR range of **2.0–3.0**.
* A target INR value of **2.5**.
* A simulated population of **100 patients**.
* Comparison of controller performance under different simulated conditions.

## Technologies and Tools

* **MATLAB**
* **Simulink**
* **PID Control**
* **Model Predictive Control (MPC)**
* **Control Systems**
* **Pharmacokinetic/Pharmacodynamic Modeling (PK/PD)**
* **Biomedical Systems Modeling**
* **Simulation and Data Analysis**

## Repository Structure

The repository is organized as follows:

* **Task_1:** Project files related to the first task.
* **Task_2:** Project files related to the second task.
* **Task_3:** Project files related to the third task.
* **Task_4:** Project files related to the fourth task.
* **Sources:** Supporting source files used in the project.
* **report:** Academic report describing the methodology, simulations, and results.

## Project Outcomes

The project explores the application of feedback and predictive control techniques to a simulated anticoagulant therapy problem.

The simulations provide a framework for analyzing INR regulation and comparing control strategies in a biomedical context.

## Academic Context

This project was developed as part of the **Control of Biological Systems** course.

The repository documents the computational models, MATLAB/Simulink implementations, and simulation analyses performed during the project.

**Disclaimer:** This project is intended for academic research and simulation purposes only. It is not a clinical decision-support tool and must not be used to determine medication doses for real patients.
