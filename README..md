# SKY130A Physical Verification — CMOS Inverter

This project documents the physical-verification flow for a CMOS inverter using the open-source SKY130A Process Design Kit (PDK). The workflow covers schematic capture, SPICE simulation, physical layout, Design Rule Checking (DRC), layout extraction, and Layout Versus Schematic (LVS) comparison using open-source EDA tools.

## Index

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

### Development environment

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

![Ubuntu system information](screenshots/01_system_info.png)

### Tools used

| Tool | Purpose |
|---|---|
| Ubuntu on WSL | Linux environment on Windows 11 |
| SKY130A / open_pdks | Process technology, device models, design rules, and integration files |
| Xschem | Schematic capture and SPICE netlist generation |
| ngspice | Pre-layout and post-layout circuit simulation |
| Magic VLSI | Physical layout, DRC, and layout extraction |
| Netgen | Layout Versus Schematic (LVS) comparison |
| Git | Version control and repository management |

### Installing and verifying the tools

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
git config --global user.name "YOUR_NAME"
git config --global user.email "YOUR_EMAIL"
```

#### Install and verify the EDA tools

Use the package manager where the available version meets your needs. If a tool is already installed and working, verify it rather than reinstalling it unnecessarily.

**Magic VLSI**

```bash
sudo apt install -y magic
which magic
magic --version
```

**Xschem**

```bash
sudo apt install -y xschem
xschem --version
xschem
```

**ngspice**

```bash
sudo apt install -y ngspice
ngspice --version
```

**Netgen**

```bash
netgen --version
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

![Magic with SKY130A](screenshots/08_magic_sky130.png)

## Chapter 1 - Understanding the design flow

### SKY130A PDK and physical layers

The SKY130A PDK provides technology files, transistor models, device libraries, and design rules for implementing and checking integrated circuits in a 130 nm CMOS process. The project uses SKY130A NFET and PFET devices to implement a CMOS inverter.

- **SPICE models:** describe transistor electrical behaviour during simulation.
- **Technology files:** define physical layers and design rules for Magic.
- **Device libraries:** provide process-specific device symbols and definitions.
- **LVS setup:** defines device recognition and comparison rules for Netgen.
- **Physical layers:** diffusion, wells, polysilicon, contacts, local interconnect, metal layers, and vias form devices and interconnections.

**SKY130A layer stack**

Add a layer-stack image as `screenshots/00_sky130_layers.png` if available.

![SKY130A physical layer stack](screenshots/00_sky130_layers.png)

### CMOS inverter design

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

### Schematic capture with Xschem

Open the inverter schematic from its project directory. Replace the example filename with the actual schematic filename if it differs.

```bash
cd ~/Lab1_and/xschem
xschem inverterr.sch
```

Generate the SPICE netlist in batch mode when needed:

```bash
xschem -n -q inverterr.sch
```

The generated netlist is typically written under the project's `netlist/` directory, depending on the Xschem configuration. Inspect it to confirm the correct SKY130A devices, pins, and parameters are present.

```bash
find . -name '*.spice' -o -name '*.cir'
```

![CMOS inverter schematic](screenshots/09a_schematic.png)

![Custom inverter symbol](screenshots/09b_symbol.png)

### Pre-layout simulation with ngspice

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

![Pre-layout testbench](screenshots/10_tb_schematic.png)

![Pre-layout simulation](screenshots/11_prelayout_simulation.png)

### Physical layout with Magic

Launch Magic with the SKY130A technology configuration and create the inverter layout using the corresponding technology layers. Place the NFET and PFET, route the input/output and supply connections, and connect all diffusion strips of the multi-finger devices correctly.

```bash
export PDK_ROOT=/usr/local/share/pdk
export PDK=sky130A
magic -rcfile "$PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc"
```

The layout should implement the same electrical connections as the schematic. A SPICE netlist can be read for reference, but importing a SPICE file does not automatically create a fully routed physical layout.

![CMOS inverter layout](screenshots/12_layout.png)

### Design-flow summary

```text
Xschem schematic
      ↓
Schematic SPICE netlist
      ↓
ngspice pre-layout simulation
      ↓
Magic physical layout
      ↓
Magic DRC
      ↓
Layout SPICE extraction
      ↓
Netgen LVS against schematic netlist
      ↓
ngspice post-layout simulation
```

## Chapter 2 - DRC and LVS Fundamentals

### Design Rule Checking

Design Rule Checking (DRC) checks the physical layout geometry against rules defined by the selected process technology. These rules include spacing, width, enclosure, overlap, and layer-specific constraints. DRC does not establish that the layout has the same electrical connectivity as the schematic.

### Layout Versus Schematic

Layout Versus Schematic (LVS) compares the circuit extracted from the physical layout with the schematic reference netlist. It checks whether devices, connections, and relevant device properties correspond. A clean DRC result and a matching LVS result are different checks, and both are required for this verification flow.

## Chapter 3 - DRC Issues

### Running DRC in Magic



Run DRC in the Magic console:

```tcl
drc check
drc count
drc why
```

Review and correct any reported violations, then rerun the checks. The final layout used for this project has zero remaining DRC violations.

![DRC result](screenshots/13_drc_clean.png)

### Reviewing and resolving violations

If Magic reports violations, inspect the reported location and rule, correct the geometry, and run the checks again. Common causes include insufficient spacing, narrow shapes, incomplete contact or via enclosure, and incorrect layer overlap. Always rerun DRC after the final layout edit.

The completed layout for this project has zero remaining DRC violations.

## Chapter 4 - LVS

### Layout extraction



After DRC, extract the layout circuit in Magic:

```tcl
extract all
ext2spice lvs
ext2spice
```

Confirm the extracted SPICE file is generated in the expected layout project directory. This extracted netlist is the layout-side input to LVS and post-layout simulation.

### Running LVS with Netgen

LVS compares the extracted layout netlist against the reference netlist generated by Xschem. Use the correct file paths, subcircuit names, and SKY130A Netgen setup file for your installation.

Example command pattern:

```bash
netgen -batch lvs \
  "../mag/inverter_1.spice inverter_1" \
  "../xschem/inverter_1.spice inverter_1" \
  "$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl" \
  /tmp/inverter_1_lvs.log
```

The filenames and subcircuit names above are examples: change them to match the actual extracted layout netlist and Xschem reference netlist. The layout netlist must be compared with the schematic netlist, not with a testbench netlist.

The final Netgen comparison for this project reports that the circuits match uniquely.

![LVS match](screenshots/14_lvs_match.png)

### Post-layout simulation

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
