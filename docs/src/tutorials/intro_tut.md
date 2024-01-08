# Tutorials

These tutorials were developed to gradually introduce new users to the various relevant functionalities and packages of VPL. These tutorials provide a step-by-step guide on how to construct, simulate, and visualize FSP models using VPL. By following these tutorials, users will gain a comprehensive understanding of the different features and capabilities offered by VPL, enabling them to use this powerful tool for their modeling needs.

Tutorials are organized in different sections:
- Getting started with VPL

| Title | TL;DR |
|:---|:---|
| [Algae growth]() | Create ‘Graph’, and update it with rewriting rules. Visualize 'Graph'. |
| [Koch snowflake]() | Define parameter for graph-nodes. Create 'Scene' and define methods for VirtualPlantLab.feed! functions. |

- From tree to forest

| Title | TL;DR |
|:---|:---|
| [Tree]() | Define different types of nodes (introduction to name spaces). Store data and define parameters at graph and graph-node level. |
| [Forest]() | Modify tree parameters within a forest. Multithreaded simulation. Scene customization and exportation. |
| [Growth forest]() | Growth rules, based on the dimension and biomass accumulation. Update dimensions in the function of assimilates and compute sink strength. Merge Scenes. Generate forest on the grid and retrieve canopy-level data. |
| [Ray-traced forest]() | Combine forest growth model with ray-tracer to simulate PAR interception. Define material as a parameter for each object type. Create sky. Layer different types of radiation in sky domes. Combine graph and sky with ray tracer. Compute growth and biomass production according to PAR interception. |

- More on rules and queries

| Title | TL;DR |
|:---|:---|
| [Context sensitive rules]() | Relational rules based on properties of neighboring nodes. Capturing the context of a node. Use queries that retrieve nodes based on relational rules or context. |
| [Relational queries]() | Use relational queries to establish relationships between nodes in a graph. |