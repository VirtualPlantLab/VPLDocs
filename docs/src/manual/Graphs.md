# [Dynamic graph creation and manipulation](@id manual_graph)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University

## Graphs, Rules and Queries

A model in VPL is a (discrete) dynamical model that describes the time evolution
of one or more entities (i.e. objects of type `graph`). Each graph  (usually
assumed to be an individual plant) is characterized by a series of nodes
(usually organs) that are represented by nodes in a graph. Each node is
defined by its own state, including (if applicable) a description of its geometry,
color, optical propertes, etc. The dynamic simulation of a graph consists of the
creation and destruction of nodes via graph rewriting rules, and changes to
the internal state of its nodes with the help of queries.

The 3D structure of a graph is generated by processing its nodes using a
**Turtle** procedural geometry approach (i.e. inspired on Logo's turtle graphs
as used in L-systems) and following the topology of the graph. This 3D structure
may be used for visualization using a 3D renderer or for simulating  spatial
processes.

VPL does not provide a domain-specific language to implement rules and queries.
Rather, they are defined by functions which are stored in objects of types `Rule`
and `Query`, respectively. Similarly, the nodes of a graph can be of any
user-defined type, as long as the user defines the necessary methods to support
specific functionality (e.g. the `feed!` method to generate geometry).

VPL is designed around data types and methods. Building a model in VPL typically
requires:

* Defining types for the different classes of nodes of a graph
* Creating rules and queries based on these types
* Creating graphs by combining rules and the initial states of the graphs
* Creating additional elements in the scene (e.g. soil)

A simulation in VPL consists of executing rules iteratively and, within each iteration:

* Use queries to select subset of nodes and modify their states.
* Modify graph-level variables directly.
* Use algorithms in VPL to simulate interactions among nodes or between nodes and their environment.

In addition, VPL allows visualizing the results of a simulation by:
* 3D rendering of the generated scenes
* Network graph representing the nodes in the graph

VPL is designed to facilitate modular model development, such as using different
types of graphs in the same simulation, alternative visualizations of the same
scene by mapping internal states of nodes to colors, or including multiple
ray tracers in the same simulation. Users may also create their own data types
that include graphs as fields or to nest graphs within other graphs.

# Graph

A graph is the basic unit of a model in VPL. Three types of data are stored
inside a graph:

* Components of the graph.
* Graph rewriting rules.
* An user-defined object that characterizes the state of a graph besides its nodes (i.e. graph-level variables).

The nodes of a graph are objects created by the user that inherit from the
abstract type `Node`. This abstract type enables describing the relationship
between nodes using a simple algebra for graph construction (see below). A
graph always needs to be initialized by at least one node (i.e. analogous
to the axiom of L-Systems), as otherwise graph rewriting rules could not be
applied.

The creation of a graph is achieved with the constructor `graph(axiom, rules[, vars])`
where `axiom`, `rules` and `vars` are the axiom, a tuple with
the graph rewriting rules and an user-defined object that stores all graph-level
variables, respectively. Note that the last argument is optional. The method
`rewrite!(graph)` takes a graph as input and executes the graph rewriting rules,
updating the internal state of the graph in-place. Note that this method will not
be called implicitly: it is the responsability of the user to decide when to call
this method.

The system is designed to allow rewriting of graphs in parallel, including shared
memory approaches such as multi-threading with the `Threads.@threads` macro. This
is ensured by deep-copying `axiom`, `rules` and `vars` so that changes in one
graph do not affect other graphs that may be built from the same axioms and rules.
If the user wants some state to be shared across graphs, they should define a global
variable that is modified during execution of rules. If such approach is used,
it is the responsibility of the user to ensure that updates to such global variables
are properly locked or executed atomatically.

## Graph-construction algebra

When initializing a graph and when specifying a graph rewriting rule it is
necessary to indicate the topological relationship between the nodes being
added to a graph (i.e. effectively we build graphs by appending sub-graphs). In
order to facilitate the description of these relationships, a simple algebra is
defined for all objects that inherit from `Node`.

The `+` operator indicates a linear parent-child dependency between the operands.
For example, `M() + L()` indicates that the object generated by `L()` is a child
of `M()`. A branching point is introduced by enclosing the children of a node
within `()` and separating the different branches with ",". For example,
`(M(1) + (L(2), L(3)) + M(4) + L(5))` creates a tree that starts with `M(1)`,
has 3 children (`L(2)`, `L(3)` and `M(4)`) and `M(4)` has a child `L(5)`.

A graph always keep tracks of two special nodes: the root and the insertion point.
The root is the node that has no parent. When you use a graph rewriting rule (see
below) to replace a node *a* with a graph that has a root node *b*, the result is
that node *a* is replaced by node *b* and will inherit all the children and parent
from node *a* (plus the children that *b* already had in the replacement graph).

An insertion point is the node of a graph where new nodes will be connected to
when using the `+` operator. Branches do not modify the insertion point of an
existing graph, but linear addition of nodes will always update the insertion
point to the last node. Thus, these two expressions produce the same tree
structure but with different insertion points: `M(1) + (L(2), L(3)) + M(4) + L(5)`
and `M(1) + (L(2), L(3), M(4) + L(5))`. In the first case, the insertion point
becomes the node `L(5)` but in the second case it remains at `M(1)`. Keeping
track of the insertion point of a graph is important when building  a graph in
several steps.

# Rules

Rules consist of directives that define the dynamic evolution of the nodes
that form a graph, by replacing a subset of the nodes by one or more nodes.
Rules are not executed directly by the user. Instead, they are stored in the
graph and executed by the method `rewrite!`. A rule is made of three parts:

* The type of node to be replaced.
* A function to determine whether a candidate node is to be replaced  or not (**lhs** function)
* A function that generates a node or subgraph to use as replacement (**rhs** function).

The first part must always be present, as it represents the minimum information
required to match the rule against nodes inside a graph. This type must be
the concrete type of the node rather an abstract type or union type from
which the node may inherit. The lhs and rhs functions are optional with the
following default values if missing:

* lhs: `x -> true`
* rhs: `x -> nothing`

A rule with a missing lhs will match all the nodes of the specified type. A
rule without an rhs will remove any matched node and all of its children
(recursively, such that the topological tree is pruned).


A `Context` object includes the data stored inside a node plus its relationship
with other nodes in the graph, as well as a reference to the graph-level
variables. In order to extract the data stored in the node use the function
`data()`. In order to extract the object containing all the graph-level variables,
use the method `vars`. The `Context` object may also be used to access other nodes
by walking through the graph (see below).

For rules that do not capture the context of a node, the lhs part
is a function that takes an object of type `Context` and returns `true` or `false`,
whereas the rhs part is a function that takes a `Context` object and returns a
node or subgraph.

Although rules may also be used to update the internal state of a node (i.e.
by creating a new node of the same type but with a different state), this is only
required when the node is an immutable type. Otherwise, one can also (and
it is recommended to) use a query for better performance (see below).

## Matching relationships among nodes

Sometimes the lhs function needs to check the relationships between nodes
inside a graph (e.g. match all leaves that belong to a particular branch of a
graph). In order achieve that, one can use the functions `hasParent()` and `hasChildren()` to
check for inmediate connections (i.e. effectively to check whether the node is a
root or a leaf in the graph) whereas `hasAncestor()` and `hasDescendant()` allow
traversing the graph and finding any connected node that matches a specific query.
If we need to extract the contents of the node, we may use the corresponding
functions `parent()`, `children()`, `ancestor()` and `descendant()`. Note that `children()`
will return all the children nodes as a tuple, but the rest of functions only
return one node at a time. All these functions take a `Context` object as input
and return either `true` or `false` (for the functions that start with `has`) or a
`Context` or tuple of `Context` objects for the functions that extract the actual
connected node. These methods may also be used inside the rhs function of rules.
However, to avoid code repetition (and for performance reasons), it is recommended
to *capture* the `Context` objects of connected in the lhs function and pass
them to the rhs as described below (see below).

 <!-- TODO: Add a table with the inputs and outputs of each graph-related method -->

## Capturing the context of a node

In some scenarios, knowing the relationship between nodes in the graph
is not sufficient, because data stored inside those related nodes is required
in the rhs function of a rule. In those cases, an extra argument to the constructor for a
`Rule` is required (`captures = true`) to indicate that this rule will pass
additional data from the lhs to the rhs function. Then, the lhs function should
return a tuple, where the first element is still `true` or `false` (to indicate
whether the rule matches a node) and the second element is a tuple of
`Context` objects associated to the nodes being matched. If no match occurs,
it is sufficient to return `(false, ())`, where `()` indicates an empty tuple.
The rhs function should then be a function that takes as first argument the
`Context` object of the node being replaced, and an additional argument for
every `Context` object being captured on the lhs function and passed to the rhs
function.

## Execution of rules

Rules are executed in the same order in which they are added to the graph object.
Then, the lhs part of each rule is tested against all nodes of the specified
type in the same order in which they were added to the graph. Similarly, the rhs
part of a rule will be applied to those nodes that matched the lhs part, in
the same order as in the matching.

<!-- TODO: Diagram on rule execution -->

The lhs part of all the rules are executed first and VPL will check that each
node is not matched by more than rule. In case there is more than one match,
an error will be generated. After all the lhs pars are executed, then the rhs parts
are executed on the matched nodes. Although generating an error may seem
restrictive, the  reasoning for this approach is as follows:

* Graph rewriting is, conceptually, a parallel operation, so two rules cannot replace the same node as that would mean the result depends on the order in which the rules are executed.

* New nodes will be generated by graph rewriting rules that could be matched by the lhs of other graph rewriting rules. To guarantee that all rules rewrite the same graph, all nodes that need to be replaced are identified before any rhs function is executed.

In essence, you need to program your model such that it does not rely on any specific order of execution of the graph rewriting rules.

# Query and `apply`

The `apply()` function will apply a `Query` object to a graph and return a list of
nodes that match the query. The main differences between rules and queries is that queries
do not have an rhs part,they are not stored inside the graph and the user
decides when to apply them. Note that that a query does not modify a graph,
it simply returns a collection of nodes matched by it. Another difference is that
a query always return a reference to the data stored  inside the node, rather
than a `Context` object (so no need to use `data()`). Note that if a query is used
to modify the data stored in a node, then the node needs to be a mutable type.

For nodes of immutable type, a graph rewriting rule must be used to replace
the node. This may seem like a limitation but the fact is that, if one needs
to modify the state of an object after it has been created then, by definition,
that object should be of mutable type. If immutability is required for some reason,
one may keep track of associated variables at the graph level, but such kind of
manual book-keeping is not recommended.

A query is useful when the data stored inside the nodes of a graph need to
be modified or when these data are used as input for some function. Unlike in
rules, the order in which queries are applied in the code will affect the result of
the simulation, especially whether they are applied before or after a call to
`rewrite!`. The reasoning for this is that queries are not altering the structure
of a graph (since they do not remove nor create nodes) and multiple queries
can (and often do) match the same node. For example, one query will alter
an internal variable that is then need as input by another query. Thus, whereas
rules implicitly follow a parallel programming paradigm, queries follow a
sequential programming paradigm.

## Direct access to nodes

It is possible to access nodes directly by their internal ID. This should be done
carefully as the internal ID depends on the internal state of VPL and may not
be reproducible across different runs, so only use it for interactive exploration
of a model. It is possible to identify the internal ID of a node by using the
method `draw()` with the default `node_label` method (see section on [Visualization](@ref manual_3d_visualization)).

The internal ID is generated by a counter inside VPL which can be reset by using
`VPL.Core.resetID()`. Once the ID of a node is known, it is possible to access
using bracket notation `[]` on a `Graph` object or any subgraph generated with
the graph construction algebra.

```julia
module L
    using VirtualPlantLab

    struct N <: Node
        val::Int
    end
end
import .L
using VirtualPlantLab
PlantGraphs.reset_id!()
axiom = L.N(1) + (L.N(3), L.N(4)) + L.N(2) + (L.N(5), L.N(6))
data(axiom[2])
```

The bracket notation will return the `Node` object that wraps the data stored
by the user. Notice how the internal ID does not match the value stored in the node, but
rather the order in which the nodes were processed during the construction of
the axiom. In this case that order coincides with reading the code left-to-right
but that will not always be the case. If we create the `Graph` object that
contains the axiom, we can access the node with the same syntax.

```julia
graph = Graph(axiom = axiom)
data(graph[2])
```
