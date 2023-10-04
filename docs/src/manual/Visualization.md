
# [3D visualization](@id manual_3d_visualization)

Alejandro Morales

Centre for Crop Systems Analysis - Wageningen University


# Introduction

VPL has two forms of visualization that are specific to a model: (i) a network representation of the graph via `draw()` and (ii) a 3D rendering of a graph or scene via `render()`. Both forms of visualization rely on the [Makie](https://makie.juliaplots.org/stable/) visualization ecosystem built into Julia. Makie allows for different backends that are relevant in different context of code execution. The backends are automatically chosen based on which Makie backend the user exports. For example if the user runs the following:

```julia
import GLMakie
```

then the native OpenGL backend will be used. Another possible backend is `WGLMakie` which will use WebGL that will render the results in an interactive web environment (this is meant to the used in interactive notebooks or special code editors such as VS Code). Finally, the `CairoMakie` backend will generate vector graphics that can be exported to pdf or svg files (not interactive). It is also possible to export static versions of any visualization in a wide range of formats (see section on [Export visualization](#exporting-visualization)).

# Drawing graphs

The function `draw()` can be applied to a `Graph` object or any subgraph (e.g.,
the axiom of graph) to visualize the network structure. This will produce a
static 2D representation of the graph.
By default, each node will be labelled with the type of object stored in it
(e.g., a turtle movement object or an user-defined object) and the internal ID
that the object has in the graph.

For example, a simple graph would be as follows:

```julia
module L
    using VirtualPlantLab

    struct N <: Node end
end
import .L
using VirtualPlantLab
import GLMakie
axiom = L.N() + (L.N(), L.N()) + L.N() + (L.N(), L.N())
draw(axiom)
graph = Graph(axiom = axiom)
draw(graph)
```

See section on [Graphs](@ref manual_graph)) and how to access nodes directly from their
internal ID for more details.

# 3D visualization

A `Scene` can be rendered in 3D using the function `render()`. To facilitate
usage, the function `render()` can be applied to a `Graph` object or an array
of `Graph` objects and it will automatically generated the corresponding `Scene`
object internally. It can also be applied to a 3D mesh (e.g., the result of a
primitive constructor, see section on [Primitives](@ref manual_primitives)).

When a mesh is being rendered directly, a default color will be used for the
mesh that the user can override (see API documentation for [`PlantViz.render`](@ref)).
Otherwise, `render()` will use the corresponding colors stored in the scene. It
is also possible to add a mesh to an existing 3D visualization by using `render!()`.

For debugging purposes, the `render()` function also allows to visualize the
edges of the triangles (`wireframe = true`) and the normal vectors (`normals = true`).

When `render()` is applied to a `Graph` object or array of `Graph` objects, it
will create internally a `Turtle` object to traverse the graph and generate the
`Scene` object. The `feed`
method takes an optional `message` argument that the user may use to control
the generation of geometry and/or colors. The `render` function allows to define
such message (any user-defined data) which will be passed along to the `feed`
methods.

Ultimately, `render()` will call the Makie function `mesh()` (or `mesh!()` for
`render!()`) and the `Figure` object from Makie. This means that any keyword argument
that is accepted by `mesh()` or `mesh!()` can be used to `render()` or `render!()`.
It also means that the use can access and modify the `Figure()` object being returned.
For example, it is possible to change the camera position, lighting, etc.
See [Makie documentation](https://docs.makie.org/stable/) for details.

# Visualization in context

Depending on the context and backend used, a different form of visualization will be obtained. The different scenarios are described below:

## Terminal

This means the code is ran from within the Julia REPL inside a terminal or command prompt (i.e., no IDE or notebook environment):

* Using the native backend will trigger an external window (entitled *Makie*) where an interactive OpenGL visualization will be rendered. The interactivity provided allows zooming and moving the camera around the visualization.

* Using the web backend will open a browser tab (unless there are some OS settings preventing, in which case a local IP address will be printed to the REPL and the user will have to manually input it into the browser) which an intetactive WebGL version will be rendered. The behaviour will be analogous to the natibe backend but note that this backend is still experimental (at the time of writing this documentation) so one should expect the ocasional bug.

* The vector backend will not display any visual output in this context. One can still export the resulting figure (see section on [Export visualization](#exporting-visualization)).

## Live interactive notebook

This means the code is running withn a Jupyter or Pluto notebook and they an active kernel or Julia session running in the background. Note that a notebook that is stored online will not be live unless it is hosted by a server that can run notebooks such as Binder or Google colab.

* The native backend will produce an inline visualization (i.e., the visualization output shows below the code cell). This will however create a static image of the 2D or 3D with the initial camera settings (not interactive).

* The web backend will generate the visualization output below the code cell and it will be interactive as long as the kernel or background Julia session keeps running.

* The vector backend will display the static output next to the code cell (but only if it is using the svg engine, which is the default).

## Visual Studio Code

IDEs that support Julia such as [Visual Studio Code](https://code.visualstudio.com/) will generally have a plot pane where visualization output is stored. This can generally be turn off (in which case the behaviour of the IDE will be the same as running from a terminal). VPL has been tested with Visual Studio Code and the [Julia extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia) and, if the plot pane is active, the behaviour will be equivalent to a live interative notebook:

* The native backend will trigger an external window rather than in the plot pane.

* The web backend will generate the visualization output in the plot pane and it will be interactive.

* The vector backend will generate the static visualization output in the plot pane.

## Document generation

This category includes a file that is processed by [Quarto](https://quarto.org/), [Documenter](https://juliadocs.github.io/Documenter.jl/stable/), [Weave](http://weavejl.mpastell.com/stable/) or [Literate](https://fredrikekre.github.io/Literate.jl/v2/). In all of these cases the final output will remain static while the visualization output should be generated inline (i.e., next to the code chunk). The following behavior has been observed with Quarto (other document generation methods have not been fully tested with VPL but are expected to behave similarly):

* For the native backend, a static snapshot of the visualization will always be inlined. The result would be as in the inline visualization of interactive notebooks.

* The web backend will not generate any visualization in the final document as this backend always requires interactivity.

* The vector backend will display the static ouput as in interactive notebooks.

## On a headless server

It will be possible to use the visualization tools even when running VPL in a headless system (e.g., a high performance computing cluster). The folliowing is based on the documentation on Makie, it has not been tested with VPL:

* The native backend will require X11 forwarding to render on the local machine or use [VirtualGL](https://www.virtualgl.org/) technology.

* The web backend will work if a Javascript serve is setup to serve the HTML content from the remote system (see [here](https://makie.juliaplots.org/stable/documentation/headless/#wglmakie) for details).

* The vector backend will generate the images correctly but the user will have to export them to pdf or svg files.

# Exporting visualization

It is possible to save any visualization generated by VPL as an external file with the `export_graph()` and `export_scene()` functions (for graph and scene visualizations, respectively). The file formats supported are png (when using `native` and `web` backends), pdf and svg (when using `vector` backend). This is possible by assigning the object returned by `draw()` or `render()` to a variable and passing that variable to the corresponding export function. This object contains all the information related to the visualization and printing it (i.e., sending it to the Julia REPL) actually causes the visualization to be created. That is, the following code:

```julia
draw(graph)
```

is equivalent to:

```julia
f = draw(graph);
f
```

Remember that `;` will prevent printing the output of whatever Julia command was executed. Saving the graph is a matter of passing `f` to `export_graph()` and assign it a file name with extension:

```julia
f = draw(graph);
export_graph(f, "<filename>.<ext>")
```

If you generate an interactive visualization, you can remove the `;` which will trigger the visualization (inlined or in an external screen) while also saving a reference to the figure inside `f`. The user may then interact with the figure (e.g., zoom in and pan around), which will automatically update `f`. That is, whatever you see on the screen will be saved to the external file. For example, rhis allows the user to save the same scene from different perspectives in separate files. The vector formats (pdf and svg) are only compatible with the `vector` backend, which does not offer interactivity. Hence, this functionality is only available for png files that will save the graph or scene generated by the `native` or `web` backends.

When drawing a graph or rendering a scene it is possible specify the resolution of the generated image as tuple of two numbers such as `resolution = (800, 600)`. In the case of `web` and `native` backends, the resolution is the actual pixels being used, whereas for the `vector` backend it is related to the actual dimensions of the figure in *points*. When the user sabes a graph or scene into an external file, the resolution may have to be chosen based on the intended physical dimensions of the figure (on screen or printed). For png images, the conversion from pixel resolution to physical dimensions is captured by the dpi (*dots per inch*) chosen at the moment of printing or displaying. In the case of vector images, as indicated before, the conventions are 1 Makie unit = 0.75 pt and 1 inch = 72 pt (these are conventions borrowed from web development such that svg images can be converted to png with altering the actual size of the image on the website). To help users, VPL offers the function `calculate_resolution()` which will compute the resolution to be used by `draw()` or `render()` in order to guarantee a particular dimension of the final exported output expressed as `width` and `height` (in cm). If we want to save the image as a png we have to specify the intended dpi:

```julia
# Compute pixel resolution to ensure a width of 6 cm, height of 16 cm and a dpi of 300
res = calculate_resolution(height = 6, width = 16, dpi = 300)
f = draw(graph, resolution = res);
using FileIO # General package for exporting or importing image files
save("<filename>.png", f)
```

In the case of vector formats, we only need to specify the width and height as the conversion between physical dimensions and pixel resolution is fixed, but we will need to specify the correct format:

```julia
# Compute pixel resolution to ensure a width of 6 cm, height of 16 cm and a dpi of 300
res = calculate_resolution(height = 6, width = 16, format = "svg")
f = draw(graph, resolution = res);
import CairoMakie # Needed to save as svg or pdf
save("<filename>.svg", f)
```

Regarding dpi, please consider that the dpi is not a property of a png image (some software include a dpi header in the image metadata, but VPL will not). It is still the responsibility of the user to ensure that the image is printed (or inserted in some document) with the correct dimensions. The `calculate_resolution()` function will simply guarantee that, once the user enforces those dimensions, the image will have the correct dpi.
