# The Virtual Plant Laboratory

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


## Introduction

The Virtual Plant Laboratory (VPL) is a collection of Julia packages that aid in the
construction, simulation and visualization of functional-structural plant models (FSPM).
Users are meant to make use of the interface package (VirtualPlantLab.jl) which provides the
API to the different packages in VPL. Additional packages complement the functionality of VPL
forming the *VPLverse* (see below for details).

VPL is not a standalone solution to all the computational problems relevant to FSPM,
but rather it focuses on those algorithms and data structures that are specific to
FSPM and for which there are no good solutions in the Julia package ecosystem.
Furthermore, VPL is 100% written in Julia and therefore VPL will work in any
platform and with any code editor where Julia works. Finally, VPL does not offer
a domain specific language for FSPM but rather it allows building FSP models by
creating user-defined data [types](https://docs.julialang.org/en/v1/manual/types/)
and [methods](https://docs.julialang.org/en/v1/manual/methods/).

There is no standard definition of what an FSPM is (though these models will
always involve some combination of plant structure and function) so VPL may
not be useful with every possible FSPM. Instead, VPL focuses on
models that represent individual plants as graphs of elements (usually organs)
that interact with each other and with the environment. In a typical VPL model,
each plant is represented by its own graph which can change dynamically through
the iterative application of graph rewriting rules. Based on this goal, what VPL
offers are data structures and algorithms that allow modelling the dynamic evolution
of graphs that represent plants as collections of organs or other morphological elements and
modelling the interaction between plants and their environment by generating 3D structures
and simulating capture of different resources (e.g. light).

In terms of design, VPL gives priority to performance and simple interfaces as
opposed to complex layers of abstraction. This implies that models in VPL may
be more verbose and procedural (as opposed to descriptive) than in other FSPM
software, but that may also make them more transparent and easier to follow.

## Installation

### Getting started with Julia and VS Code

If you are already familiar with Julia and have a working editor, skip to
[Installing VPL](@ref installing-vpl). Otherwise, the following steps will take you from
a computer without Julia to a Julia terminal (called the *REPL*) where you can install VPL.
VPL works with any code editor, but we recommend [Visual Studio Code](https://code.visualstudio.com/)
(VS Code) because it is free and has excellent support for Julia.

**1. Install Julia**

*Windows*

1. Open the Start menu, type `PowerShell` and open it.
2. Run the following command and follow the instructions on screen:

   ```
   winget install --name Julia --id 9NJNWW8PVKMN -e -s msstore
   ```

   Alternatively, install *Julia* from the Microsoft Store.

*Mac*

1. Open the *Terminal* app (press `Cmd + Space`, type `Terminal` and press `Enter`).
2. Run the following command and follow the instructions on screen:

   ```
   curl -fsSL https://install.julialang.org | sh
   ```

Both methods install `juliaup`, a small tool that installs Julia and keeps it up to date.
Close and reopen the terminal afterwards. To check that Julia was installed, type `julia`
and press `Enter`: you should see a prompt `julia>`. Type `exit()` to leave Julia. More
details (and other options such as manual downloads) are available at the
[Julia downloads page](https://julialang.org/downloads/).

**2. Install VS Code**

1. Download the installer for your system from [code.visualstudio.com](https://code.visualstudio.com/)
   (Windows: *User Installer*; Mac: the `.zip`, which you then drag into the *Applications* folder).
2. Run the installer and open VS Code.

**3. Install the Julia extension**

1. In VS Code, click the *Extensions* icon in the left sidebar (or press `Ctrl + Shift + X`,
   `Cmd + Shift + X` on Mac).
2. Search for `Julia` and install the extension called *Julia* (publisher: *julialang*).
3. Restart VS Code if requested.

**4. Open a folder and start a Julia terminal**

1. Create a folder for your VPL work (e.g. `VPL_projects`) and open it in VS Code with
   *File → Open Folder...*.
2. Open the *Command Palette* with `Ctrl + Shift + P` (`Cmd + Shift + P` on Mac), type
   `Julia: Start REPL` and press `Enter`.
3. A terminal panel will open at the bottom of VS Code showing the prompt `julia>`. This is
   the Julia REPL and it is where you type the commands below.

**5. Optional: use a project environment**

To keep the packages of each project separate, you can activate a local environment in the
REPL before installing VPL:

```julia
using Pkg
Pkg.activate(".")
```

This creates a `Project.toml` file in the current folder to record the packages you install.

### [Installing VPL](@id installing-vpl)

VPL requires using Julia version 1.9 or higher. The installation of core of VPL is as
easy as running the following code in the Julia REPL:

```julia
] add VirtualPlantLab
```

Typing `]` at the `julia>` prompt switches the REPL to *package mode* (the prompt changes
to `pkg>`), so you only need to type `add VirtualPlantLab` and press `Enter`. Press
`Backspace` to go back to the `julia>` prompt. Equivalently, you can run
`using Pkg; Pkg.add("VirtualPlantLab")` from the normal prompt.

This will install all the packages that form the core of VPL. Additional packages that are meant to work with VPL (or
as standalone packages) are available as part of the *VPLverse* (see section on
[Organization](@ref organization)). These are not necessary to build an FSP models but in
many cases they will be useful to complement the functionality of VPL.

## Documentation

In this website, documentation for VPL is provided in different formats, with different purposes or functions:

| Documentation type | User type | Function |
|:---|:---|:---|
| Tutorials | New users | The tutorials were developed to gradually introduce new users to relevant functionalities and packages of VPL to construct, simulate, and visualize FSP models. The end product is not really important, or sometimes related to FSP models, but the users learn important practical knowledge that may be useful to build your first FSP model in VPL. |
| Manual | All users | This manual describes the different concepts used in VPL and gives an overview of the options available. These include Julia concepts used in VPL, creating and manipulating dynamic graphs, ray tracing, visualization, and simulation of scenes. This manual is meant to be used the new users who are going through tutorials, as well as any other user. |
| API | All users | The API documentation describes each function and data type of the VPL core, with an emphasis on the inputs and outputs of the basic packages that provide the functionality to build FSP models. In addition to this website, it can be accessed from within Julia with `?` (see [Documentation](https://docs.julialang.org/en/v1/manual/documentation/) in the Julia manual). |
| VPLverse | All users | The API and package documentation for each component of VPLverse, the ecosystem of packages built around VPL that provide additional support to plant modelers to implement ecophysiology and biophysical processes, simulate and model plants, soil, and atmosphere, as well as simulate different sky conditions and light distribution. In addition to this website, it can be accessed from within Julia with `?`. |
| How-to guides | All users | These guides target specific issues or objectives in the context of working with FSP models on VPL. In contrast to tutorials, how-to guides focus on individual problems and their intricacies. The objective is to acquaint users with specific functionalities, eliminating the need for users to repeatedly go back to tutorials to find problem-solving information. |
| Developers | Advanced users | This documentation is useful for people who want to understand the internal details of VPL and how algorithms are implemented. Additionally, it guides users on the development of packages and styling protocol adopted for VPL and VPLverse. |
