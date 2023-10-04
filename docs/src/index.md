# The Virtual Plant Laboratory

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


## Introduction

The Virtual Plant Laboratory (VPL) is a Julia package that aids in the construction,
simulation and visualization of functional-structural plant models (FSPM). VPL
is not a standalone solution to all the computational problems relevant to FSPM,
but rather it focuses on those algorithms that are specific to
FSPM and for which there are no good solutions in the Julia package ecosystem.
Furthermore, VPL is 100% written in Julia and therefore VPL will work in any
platform and with any code editor where Julia works. Finally, VPL does not offer
a domain specific language for FSPM but rather it allows building FSP models by
creating user-defined data [types](https://docs.julialang.org/en/v1/manual/types/)
and [methods](https://docs.julialang.org/en/v1/manual/methods/).

There is no standard definition of what an FSPM is (though these models will
always involve some combination of plant structure and function) so VPL may
not be useful with every possible FSPM. Instead, VPL focuses on
models that represent indivudual plants as graphs of elements (usually organs)
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
software, though may also make them more transparent and easier to follow.

## Installation

VPL requires using Julia version 1.9 or higher. The installation of VPL is as
easy as running the following code:

```julia
] add VirtualPlantLab
```

This requires an Internet connection such that Julia will download the source code of the VPL package
and install it in the local machine. Note that throughout this documentation, we will refer
to VPL for short, but the actual name of the Julia package is `VirtualPlantLab` (the Julia
community is not fond of short acronyms as package names).

## The *VPLverse*

VPL contains all the basic functionality to build FSP models but, as
indicated earlier, the emphasis is on minimal, simple and transparent interfaces.
In order to facilitate the construction of non-trivial FSP models, an ecosystem of
packages built around VPL provide additional support to the modeller by offering
reusable modules that can be reused in new models.

The packages currently planned for *VPLverse* are:

* *Ecophys.jl* - Algorithms and data structures to simulate ecophysiological processes
including photosynthesis, transpiration, leaf energy balance, phenology or respiration.

* *SkyDomes.jl* - Algorithms to simulate different sky conditions in terms of the intensity of
solar radiation and its spatial and angular distribution.

## Documentation

Documentation for VPL is provided in this website in four formats:

1. User manual
2. Tutorials
3. API
4. Technical notes (in development)

The documentation for packages from the *VPLverse* are included in their respective sections.

New users are expected to start with the tutorials and consult the user manual
to understand better the different concepts used in VPL and get an overview of
the different options available. The API documentation describes each individual
function and data type, with an emphasis on inputs and outputs and (in addition
to this website) it can be accessed from within Julia with `?` (see the section
[Accessing Documentation](https://docs.julialang.org/en/v1/manual/documentation/#Accessing-Documentation-1)
in the Julia manual).

The technical notes are useful for people who want to understand the internal details of VPL
and how different algorithms are implemented (i.e. the technical notes should be seen as a
supplementary to the source code of VPL). The technical notes are not intended to be read
by casual users but rather by those who seek a deeper understanding of internal structure
and code behind VPL.
