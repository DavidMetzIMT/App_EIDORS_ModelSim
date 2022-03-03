# app_eidors_modelsim

Model Simulation Reconstruction software for Electrical Impedance Tomography (EIT)

Thank you for the interest in `app_eidors_modelsim`!

`app_eidors_modelsim` is a MATLAB-based, open-source framework for Modeling 
Simulation Reconstruction of Electrical Impedance Tomography (EIT) setup.


## 1. Introduction

### 1.1 Dependencies

This MATLAB-based framework is based on the toolbox [`EIDORS`](http://eidors3d.sourceforge.net/)

### 1.2 Features
 - [x] Generation Forward model
    - [x] Setting of the forward solver
    - [x] Generation of measurement chamber 2D (circle) and 3D (cylinder/cubic) using netgen
    - [x] Generation of electrodes layout ring and array (only for 3D on top or bottom surface)
    - [x] Generation of injection and measurements pattern
 - [x] Simulation of measurements
    - [x] Setting of the conductivity by adding objects (cells, sphere, cylinder) in the chamber
    - [x] Solving of the forward problem
 - [x] Reconstruction of measurements
    - [x] Setting of the inverse solver
    - [x] Loading real measurement or simulation 
    - [x] Solving of the inverse problem 
 - [x] Plotting
    - [x] FEM mesh of the forward model
    - [x] Pattern
    - [x] Simulation results (FEM/ measurements Uplots)
 - [x] Generation of dataset for AI
    - [x] Generation of Simulation of measurements
    - [x] Samples data extraction for python-based AI computation

	
## 2. Installation


`app_eidors_modelsim` is an MATLAB-App based. No special insatllation is needed.

besides this package, the EIDORS toolbox is needed:
- Download the toolbox "eidors-v3.10-ng.zip" [here](http://eidors3d.sourceforge.net/download.shtml)
- extract it on your local machine (prefer those path '/usr/local/EIDORS', 'C:\EIDORS')


## 3. Run the app

Run the script 'start.m' 
```
>> start.m
```

### 3.1 Examples of Forward Model

#### 3.1.1 Examples of Chamber designs with differents electrodes combination

**Circle_elec_ring_wall**

![Circle_elec_ring_wall](/doc/images/Circle_elec_ring_wall.png)

**Cylinder_elec_ring_wall**

![Cylinder_elec_ring_wall](/doc/images/Cylinder_elec_ring_wall.png)

**Cylinder_elec_ring_top**

![Cylinder_elec_ring_top](/doc/images/Cylinder_elec_ring_top.png)

**Cylinder_elec_ring_bot**

![Cylinder_elec_ring_bot](/doc/images/Cylinder_elec_ring_bot.png)

**Cylinder_elec_ring_top_array_bot**

![Cylinder_elec_ring_top_array_bot](/doc/images/Cylinder_elec_ring_top_array_bot.png)

**Cubic_elec_ring_top_array_bot**

![Cubic_elec_ring_top_array_bot](/doc/images/Cubic_elec_ring_top_array_bot.png)

#### 3.1.2 Examples of Forward Model

#### 3.1.3 Examples of Forward Model

### 3.2 Simulation / Forward Solving (2D/3D)
#### 3.2.2 Example of simulation
#### 3.2.1 Object definition

### 3.2 Reconstruction / Inverse Solving (2D/3D)

### 3.3 Generation of AI
#### 3.3.1 Example of dataset generation
#### 3.3.2 

## 4. Cite our work.

**If you find `app_eidors_modelsim` useful, please cite our work!**


