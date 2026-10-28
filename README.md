# Exploring the SKY130 Open-Source VLSI Flow

This repository documents my hands-on work setting up and exploring the SkyWater SKY130 process design kit with open-source electronic design automation (EDA) tools. It is a practical learning log: setup steps, commands, configuration notes, experiments, errors encountered, and verified results are added as the work progresses.

The focus is on understanding how schematic design, circuit simulation, layout, and physical verification fit together in a small VLSI workflow.

## Project scope

The work is organized around these stages:

1. Prepare an Ubuntu environment for open-source EDA tools.
2. Configure the SKY130 PDK and its tool-specific files.
3. Use Xschem to inspect or create a circuit schematic and generate a SPICE netlist.
4. Use ngspice to simulate the circuit and examine its response.
5. Explore layout creation and design-rule checking (DRC) with Magic.
6. Compare schematic and layout-extracted netlists with Netgen for layout-versus-schematic (LVS) checking.
7. Record results and troubleshooting notes so the steps can be repeated.

The exact scope may grow as more exercises are completed. A step is marked complete only after it has been run and its output checked.

## Tools and what I am learning

| Tool | Role in this project |
| --- | --- |
| [SkyWater SKY130 PDK](https://github.com/google/skywater-pdk) | Process design kit containing technology data, device models, and related files |
| [Xschem](https://xschem.sourceforge.io/) | Schematic capture and SPICE netlist generation |
| [ngspice](https://ngspice.sourceforge.io/) | Circuit-level simulation |
| [Magic](http://opencircuitdesign.com/magic/) | IC layout editing, extraction, and design-rule checking |
| [Netgen](http://opencircuitdesign.com/netgen/) | Netlist comparison for LVS |
| [OpenLane](https://openlane2.readthedocs.io/) | A possible later step for an automated RTL-to-GDSII flow |

These tools have different roles. Generating a netlist does not by itself prove that a simulation works, and installing Magic or Netgen does not mean DRC or LVS has passed.

## Current progress

This table should be updated as work is verified.

| Task | Status |
| --- | --- |
| Ubuntu / WSL environment setup | In progress / environment-dependent |
| Xschem and SKY130 library configuration | In progress |
| SPICE netlist generation | Add result after checking the generated file |
| ngspice simulation | Pending verified run and waveform |
| Magic layout and DRC | Pending |
| Netgen LVS comparison | Pending |
| OpenLane setup | Not yet verified |

## Suggested repository layout

```text
.
├── README.md
├── docs/
│   ├── setup.md
│   ├── workflow.md
│   └── troubleshooting.md
├── xschem/                  # Source schematics and local notes
├── spice/                   # Generated netlists and testbenches
├── physical_verification/    # Magic layouts, extraction notes, DRC/LVS reports
└── results/                  # Selected screenshots, waveforms, and logs
```

Only add files that are actually created during the work. Avoid committing the entire PDK, large generated build directories, or machine-specific temporary files.

## Workflow notes

### 1. Environment and PDK

Record the Ubuntu version, installation method, tool versions, PDK revision, and relevant configuration paths. Paths differ depending on whether tools were installed from distribution packages, built from source, or installed through a dedicated flow.

### 2. Schematic and netlist

Use Xschem with the intended SKY130 symbols and model setup. Save the original schematic under `xschem/` and place the generated SPICE netlist or testbench under `spice/`. Review model includes and file paths before running a simulation.

### 3. Circuit simulation

Run the appropriate netlist with ngspice. Save the command, important output, and a waveform showing the signals being investigated. Document any warnings or errors rather than omitting them.

### 4. Layout and physical verification

If a layout is created in Magic, record the technology configuration and layout cell. Run the applicable DRC checks and preserve a concise report. Extract the layout netlist and compare it with the corresponding schematic netlist using Netgen and the appropriate SKY130 setup file.

A DRC or LVS result should be described as passing only when the tool output supports that conclusion. If checks have not yet been run, leave them marked as pending.

## Setup and troubleshooting

See the `docs/` directory for detailed commands and notes. One environment issue encountered during setup was pip's `externally-managed-environment` restriction when attempting to install OpenLane into the system Python environment. The OpenLane installation should be completed using a supported method for the selected version; it should not be considered installed until its verification step succeeds.

For each issue, record:

- the exact command and error message
- the environment and tool version
- the cause, if identified
- the fix attempted
- whether the fix was verified

## Results and evidence

Useful evidence to add as it becomes available:

- Xschem schematic screenshot
- generated SPICE netlist
- ngspice run log and waveform
- Magic layout screenshot
- DRC report
- layout-extracted netlist and Netgen LVS report
- tool versions and commands used

Use descriptive filenames and remove private information such as usernames, credentials, or unrelated desktop content from screenshots and logs.

## References

- [SkyWater SKY130 PDK](https://github.com/google/skywater-pdk)
- [SKY130 documentation](https://skywater-pdk.readthedocs.io/)
- [Xschem](https://xschem.sourceforge.io/)
- [ngspice](https://ngspice.sourceforge.io/)
- [Magic VLSI](http://opencircuitdesign.com/magic/)
- [Netgen](http://opencircuitdesign.com/netgen/)
- [OpenLane 2 documentation](https://openlane2.readthedocs.io/)

The repository linked as background reading, [Physical_Verification_SKY130A](https://github.com/yathAg/Physical_Verification_SKY130A), is useful for understanding physical verification topics. This repository is written independently and is intended to record my own setup, experiments, and results rather than reproduce another project's workshop notes.

## Disclaimer

This is an independent educational project and is not an official SkyWater, Google, or OpenLane repository. Tool names and project names belong to their respective owners.
