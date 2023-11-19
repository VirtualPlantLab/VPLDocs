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

VPL requires using Julia version 1.9 or higher. The installation of core of VPL is as
easy as running the following code:

```julia
] add VirtualPlantLab
```

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
