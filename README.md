# SKY130A Physical Verification — CMOS Inverter

This project documents the physical-verification flow for a CMOS inverter using the open-source SKY130A Process Design Kit (PDK). The workflow covers schematic capture, SPICE simulation, physical layout, Design Rule Checking (DRC), layout extraction, and Layout Versus Schematic (LVS) comparison using open-source EDA tools.


## 1. Project overview
Physical verification checks whether an IC layout follows the manufacturing design rules and represents the intended electrical circuit. This project uses a CMOS inverter as a small example of the complete schematic-to-layout verification loop.

The inverter uses:
- One SKY130A NMOS transistor (NFET).
- One SKY130A PMOS transistor (PFET).
- A common input connected to both transistor gates.
- A common output connected to the transistor drains.
- VDD and VSS supply connections.
The expected logic is:
Input	Output
LOW	HIGH
HIGH	LOW


The schematic is captured in Xschem, simulated with ngspice, laid out in Magic, checked with DRC, extracted to SPICE, and compared against the schematic netlist with Netgen LVS.
Main verification terms
- PDK: Process Design Kit; includes technology files, device models, design rules, and supporting libraries.
- DRC: Design Rule Check; checks geometry against the technology's layout rules.
- LVS: Layout Versus Schematic; compares the circuit extracted from the layout with the reference schematic netlist.
- Extraction: Converts layout geometry into an electrical netlist and may include parasitic information.
- Pre-layout simulation: Simulation using the schematic-level circuit.
- Post-layout simulation: Simulation using the extracted layout circuit, potentially including parasitic effects.


## 2. Workflow at a glance
```text
Ubuntu / WSL environment
          |
          v
Install Magic, Xschem, ngspice, Netgen and SKY130A PDK
          |
          v
Configure each tool to use the same SKY130A installation
          |
          v
Draw CMOS inverter in Xschem
          |
          v
Generate schematic SPICE netlist
          |
          v
Build testbench and run pre-layout transient simulation
          |
          v
Create transistor layout in Magic
          |
          v
Run DRC and fix geometry violations
          |
          v
Extract layout SPICE netlist
          |
          v
Run Netgen LVS against the Xschem reference netlist
          |
          v
Simulate the extracted circuit in ngspice
          |
          v
Archive the completed results, reports, and project files in Git

```


## 3. Contents

- [Chapter 0 - Getting the tools](#chapter-0---getting-the-tools)
  - [Development environment](#development-environment)
  - [Tools used](#tools-used)
  - [Installing and verifying the tools](#installing-and-verifying-the-tools)
  - [SKY130A PDK setup and integration](#sky130a-pdk-setup-and-integration)
- [Chapter 1 - Understanding the design flow](#chapter-1---understanding-the-design-flow)
  - [SKY130A PDK and physical layers](#sky130a-pdk-and-physical-layers)
  - [CMOS inverter design](#cmos-inverter-design)
  - [Schematic capture with Xschem](#schematic-capture-with-xschem)
  - [Pre-layout simulation with ngspice](#pre-layout-simulation-with-ngspice)
  - [Physical layout with Magic](#physical-layout-with-magic)
- [Chapter 2 - DRC and LVS Fundamentals](#chapter-2---drc-and-lvs-fundamentals)
  - [Design Rule Checking](#design-rule-checking)
  - [Layout Versus Schematic](#layout-versus-schematic)
- [Chapter 3 - DRC Issues](#chapter-3---drc-issues)
  - [Running DRC in Magic](#running-drc-in-magic)
  - [Reviewing and resolving violations](#reviewing-and-resolving-violations)
- [Chapter 4 - LVS](#chapter-4---lvs)
  - [Layout extraction](#layout-extraction)
  - [Running LVS with Netgen](#running-lvs-with-netgen)
  - [Post-layout simulation](#post-layout-simulation)
  - [Observations and key learnings](#observations-and-key-learnings)
- [Repository structure](#repository-structure)
- [References](#references)

---

## Chapter 0 - Getting the tools

### 0.1 Development environment

- **Host OS:** Windows 11
- **Linux environment:** Ubuntu through WSL (not a traditional virtual machine)
- **PDK root:** `/usr/local/share/pdk`
- **SKY130A directory:** `/usr/local/share/pdk/sky130A`
- **Project workspace:** `~/Lab1_and/xschem` (adjust if your project is stored elsewhere)

Check the Linux environment and system resources:

```bash
lsb_release -a
uname -a
free -h
df -h /
nproc
```

<img width="857" height="747" alt="Screenshot 2026-10-30 081220" src="https://github.com/user-attachments/assets/46771b22-f369-4a90-ba7d-8c365d0fdea5" />


### 0.2 Tools used

| Tool | Purpose |
|---|---|
| Ubuntu on WSL | Linux environment on Windows 11 |
| SKY130A / open_pdks | Process technology, device models, design rules, and integration files |
| Xschem | Schematic capture and SPICE netlist generation |
| ngspice | Pre-layout and post-layout circuit simulation |
| Magic VLSI | Physical layout, DRC, and layout extraction |
| Netgen | Layout Versus Schematic (LVS) comparison |
| Git | Version control and repository management |

### 0.3 Installing and verifying the tools

#### Update Ubuntu and install dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  build-essential git make gcc g++ cmake autoconf automake \
  libtool pkg-config m4 flex bison tcl-dev tk-dev \
  libx11-dev libxext-dev libxrender-dev libxpm-dev \
  libxaw7-dev libcairo2-dev wget curl ca-certificates
```

Install or verify Git:

```bash
sudo apt install -y git
git --version

```
<img width="887" height="192" alt="image" src="https://github.com/user-attachments/assets/2d94b784-c98d-40c2-a5c7-30434f0d391c" />

#### 0.4 Install and verify the EDA tools

Use the package manager where the available version meets your needs. If a tool is already installed and working, verify it rather than reinstalling it unnecessarily.



**Magic VLSI**

```bash
$  git clone git://opencircuitdesign.com/magic
$  cd magic
$	 ./configure
$  make
$  sudo make install
```
verify magic 
<img width="1920" height="1080" alt="Screenshot (1474)" src="https://github.com/user-attachments/assets/0e017dd8-3c86-4418-ab00-27f275adbf55" />



**Xschem**

```bash
$  git clone https://github.com/StefanSchippers/xschem.git xschem_git
$	./configure
$  make
$  sudo make install
```
verify xschem
<img width="1920" height="1080" alt="Screenshot (1503)" src="https://github.com/user-attachments/assets/4f37b092-9666-436a-940a-439ff4bb5fd2" />



**ngspice**

```bash
sudo apt install -y ngspice
ngspice --version
```
verify ngspice
<img width="1920" height="1080" alt="Screenshot (1504)" src="https://github.com/user-attachments/assets/6056f5eb-53ba-46f1-94d8-5a1228bf36c3" />



**Netgen**

```bash
$  git clone git://opencircuitdesign.com/netgen
$  cd netgen
$	./configure
$  make
$  sudo make install
```
verify netgen
<img width="1920" height="1080" alt="Screenshot (1505)" src="https://github.com/user-attachments/assets/1b892b4d-f466-45fc-88b7-a8d8faa3aa0f" />



**SKY130PDK**

```bash
$  git clone git://opencircuitdesign.com/open_pdks
$  open_pdks
$	./configure --enable-sky130-pdk
$  make
$  sudo make install
```

If a required tool version is unavailable through Ubuntu packages, use the official project instructions to build it from source. For example, a source build of Magic can follow this pattern:

```bash
git clone https://github.com/RTimothyEdwards/magic.git magic-src
cd magic-src
./configure
make
sudo make install
cd ..
which magic
magic --version
```

Source-build instructions and dependencies may vary by release; use the relevant tool's documentation if the build process differs.



### SKY130A PDK setup and integration

#### Check the SKY130A PDK

```bash
export PDK_ROOT=/usr/local/share/pdk
export PDK=sky130A
ls "$PDK_ROOT/sky130A/libs.tech/"
ls "$PDK_ROOT/sky130A/libs.tech/magic/"
ls "$PDK_ROOT/sky130A/libs.tech/netgen/"
ls "$PDK_ROOT/sky130A/libs.tech/ngspice/"
```
verifing that SKY130A PDK technology files and supporting libraries used by Magic, Netgen, and NGSpice.
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/1072819a-7601-4b3a-bf77-ff18299db9fc" />


To make the environment variables available in future terminals, add them to `~/.bashrc` and reload it:

```bash
echo 'export PDK_ROOT=/usr/local/share/pdk' >> ~/.bashrc
echo 'export PDK=sky130A' >> ~/.bashrc
source ~/.bashrc
```

Confirm the SKY130A SPICE model library exists:

```bash
ls "$PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice"
```


Example Magic launch using the installed SKY130A technology setup:

```bash
export PDK_ROOT=/usr/local/share/pdk
export PDK=sky130A
magic -rcfile "$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc"
```

Inside Magic, the technology should load as SKY130A. If Magic falls back to the `minimum` technology or reports a technology-file parsing error, resolve the compatibility issue before running layout checks; a Magic version and PDK technology-file mismatch can prevent correct DRC.




## Chapter 1 - Understanding the design flow

### 1.1 SKY130A PDK and physical layers

The SKY130A PDK provides technology files, transistor models, device libraries, and design rules for implementing and checking integrated circuits in a 130 nm CMOS process. The project uses SKY130A NFET and PFET devices to implement a CMOS inverter.

- **SPICE models:** describe transistor electrical behaviour during simulation.
- **Technology files:** define physical layers and design rules for Magic.
- **Device libraries:** provide process-specific device symbols and definitions.
- **LVS setup:** defines device recognition and comparison rules for Netgen.
- **Physical layers:** diffusion, wells, polysilicon, contacts, local interconnect, metal layers, and vias form devices and interconnections.

### 1.2 CMOS inverter design

The CMOS inverter uses an NFET pull-down device and a PFET pull-up device. Both gates share the input, both drains form the output, the NFET source/body connect to VSS, and the PFET source/body connect to VDD.

| Parameter | NFET | PFET |
|---|---|---|
| SKY130A model | `sky130_fd_pr__nfet_01v8` | `sky130_fd_pr__pfet_01v8` |
| Width (W) | 4.5 µm | 3 µm |
| Length (L) | 0.18 µm | 0.18 µm |
| Fingers (`nf`) | 3 | 3 |
| Body connection | VSS | VDD |

Expected logic:

| Input | Output |
|---|---|
| LOW | HIGH |
| HIGH | LOW |


### 1.3 Inverter schematic  using xschem

```bash
cd ~/Lab1_and/xschem
xschem inverterr.sch
```

Generate the SPICE netlist in batch mode when needed:

```bash
xschem -n -q inverterr.sch
```

The schematic is initially developed using devices from the Open PDK library. Parameter and property modifications can be made directly in the schematic, and these updates are automatically synchronized with the layout.


The generated netlist is typically written under the project's `netlist/` directory, depending on the Xschem configuration. Inspect it to confirm the correct SKY130A devices, pins, and parameters are present.

```bash
find . -name '*.spice' -o -name '*.cir'
```

<img width="1920" height="1080" alt="Screenshot (1480)" src="https://github.com/user-attachments/assets/774f4a5a-b48c-4893-9609-ce70a4e2badb" />
<img width="1920" height="1080" alt="Screenshot (1483)" src="https://github.com/user-attachments/assets/495e4da1-a616-4464-8b3f-9f52381cff74" />

### 1.4 Pre-layout simulation with ngspice

Create a testbench that instantiates the inverter subcircuit, supplies the required power voltage, and applies a pulse input. Include the SKY130A model library and the generated schematic netlist using paths that match your project.

A typical testbench contains these elements:

```spice
.lib "/usr/local/share/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice" tt
.include "inverterr.spice"

VDD vdd 0 DC 1.8
VIN in 0 PULSE(0 1.8 0 100p 100p 5n 10n)
* Use the subcircuit name and pin order defined by your generated netlist.
XINV vdd out in 0 inverterr

.control
tran 10p 40n
plot V(in) V(out)
.endc
.end
```

Check the `.subckt` declaration in the generated netlist and make sure the instance pin order matches it exactly before simulation. Run the testbench with ngspice:

```bash
ngspice inverterr_tb.spice
```

The expected waveform has the output switching opposite to the input.

<img width="1920" height="1080" alt="Screenshot (1488)" src="https://github.com/user-attachments/assets/bdd25cd0-79b0-4c81-be11-ed3488505485" />


### 1.5 Physical layout with Magic

Launch Magic with the SKY130A technology configuration and create the inverter layout using the corresponding technology layers. Place the NFET and PFET, route the input/output and supply connections, and connect all diffusion strips of the multi-finger devices correctly.

```bash
export PDK_ROOT=/usr/local/share/pdk
export PDK=sky130A
magic -rcfile "$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc"
```

The layout should implement the same electrical connections as the schematic. A SPICE netlist can be read for reference, but importing a SPICE file does not automatically create a fully routed physical layout.

<img width="1920" height="1080" alt="Screenshot (1499)" src="https://github.com/user-attachments/assets/b5d43a0c-615a-4e11-ba89-24ef0fca1f02" />




## Chapter 2 - DRC and LVS Fundamentals

### 2.1 Design Rule Checking

Design Rule Checking (DRC) checks the physical layout geometry against rules defined by the selected process technology. These rules include spacing, width, enclosure, overlap, and layer-specific constraints. DRC does not establish that the layout has the same electrical connectivity as the schematic.

### 2.2 Layout Versus Schematic

Layout Versus Schematic (LVS) compares the circuit extracted from the physical layout with the schematic reference netlist. It checks whether devices, connections, and relevant device properties correspond. A clean DRC result and a matching LVS result are different checks, and both are required for this verification flow.

## Chapter 3 - DRC Issues

### 3.1 Running DRC in Magic



Run DRC in the Magic console:

```tcl
drc check
drc count
drc why
```

Review and correct any reported violations, then rerun the checks. The final layout used for this project has zero remaining DRC violations.

<img width="1920" height="1080" alt="Screenshot (1501)" src="https://github.com/user-attachments/assets/1e99a7dc-7501-49d1-886c-b6accb9a543d" />


### 3.2 Reviewing and resolving violations

If Magic reports violations, inspect the reported location and rule, correct the geometry, and run the checks again. Common causes include insufficient spacing, narrow shapes, incomplete contact or via enclosure, and incorrect layer overlap. Always rerun DRC after the final layout edit.

The completed layout for this project has zero remaining DRC violations.

## Chapter 4 - LVS

### 4.1 Layout extraction



After DRC, extract the layout circuit in Magic:

```tcl
extract all
ext2spice lvs
ext2spice
```

Confirm the extracted SPICE file is generated in the expected layout project directory. This extracted netlist is the layout-side input to LVS and post-layout simulation.

### 4.2 Running LVS with Netgen

LVS compares the extracted layout netlist against the reference netlist generated by Xschem. Use the correct file paths, subcircuit names, and SKY130A Netgen setup file for your installation.

Example command pattern:

```bash
netgen -batch lvs \
  "/home/Sagarikaa1/Lab1_and/mag/inverterr.spice inverterr" \
  "/home/Sagarikaa1/Lab1_and/xschem/netlist/inverterr.spice inverterr" \
  /home/Sagarikaa1/Lab1_and/netgen/sky130A_setup.tcl \
  /tmp/inverterr_lvs.log
```

The filenames and subcircuit names above are examples: change them to match the actual extracted layout netlist and Xschem reference netlist. The layout netlist must be compared with the schematic netlist, not with a testbench netlist.

The final Netgen comparison for this project reports that the circuits match uniquely.

<img width="1920" height="1080" alt="Screenshot (1498)" src="https://github.com/user-attachments/assets/fe9eef63-7081-4261-8fc6-e5e0a90f4692" />


### 4.3 Post-layout simulation

Use the extracted layout SPICE netlist in a simulation testbench. Include the SKY130A model library, apply the same supply and input stimulus used for pre-layout simulation, and ensure the inverter subcircuit name and pin order match the extracted file.

```bash
ngspice postlayout_tb.spice
```

Compare the pre-layout and post-layout waveforms. Both should preserve the inverter's complementary input-output logic; the extracted netlist may also represent layout-related parasitic effects, depending on the extraction settings.

![Pre-layout and post-layout simulation](screenshots/15_pre_vs_post_layout_simulation.png)

### Observations and key learnings



- The pre-layout waveform demonstrates the expected complementary input and output behaviour.
- The final Magic layout has zero remaining DRC violations.
- Netgen reports a unique match between the extracted layout circuit and the schematic reference.
- The extracted layout netlist can be used for post-layout simulation and comparison with the schematic-level result.



- **PDK integration matters:** Magic, Xschem, ngspice, and Netgen must use compatible SKY130A technology files, models, and setup files.
- **Multi-finger transistor routing matters:** All source and drain diffusion regions must be connected as intended. Unconnected diffusion regions can appear as extra devices or nets during extraction and cause LVS mismatches.
- **DRC and LVS check different things:** DRC checks geometry against design rules; LVS checks whether the extracted circuit corresponds to the reference schematic.
- **Netgen reports help debugging:** Differences in device and net counts can point to incorrect or missing connections.
- **Post-layout simulation adds context:** Comparing schematic and extracted-layout waveforms helps identify the impact of layout extraction on circuit behaviour.

## Repository Structure

```text
SKY130A-Physical-Verification-Project/
├── README.md
├── Lab1_inverter/
│   ├── xschem/       # Schematic, symbol, testbench, reference netlist
│   ├── mag/          # Magic layout and extracted files
│   ├── netgen/       # LVS setup and comparison report
│   └── ngspice/      # Simulation testbenches and waveform data
└── screenshots/      # Screenshots of the setup, schematic, layout, and results
```

Keep the actual `.sch`, `.sym`, `.mag`, extracted `.spice`, simulation testbenches, and LVS report in the corresponding folders. Add screenshots using the filenames referenced in this README, or update the image paths to match your filenames. The screenshot links are placeholders until the images are added to the repository.

## References

- [SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/)
- [Magic VLSI](http://opencircuitdesign.com/magic/)
- [Netgen LVS](http://opencircuitdesign.com/netgen/)
- [Xschem](https://github.com/StefanSchippers/xschem)
- [ngspice documentation](https://ngspice.sourceforge.io/docs.html)
- [open_pdks](https://github.com/RTimothyEdwards/open_pdks)
- [Reference repository](https://github.com/ananyarf/VLSI-Physical-Verification-Sky130A)
