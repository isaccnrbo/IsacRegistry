# Install Julia

To install julia, use the Julia version manager [`juliaup`](https://github.com/JuliaLang/juliaup). Install any version from `Julia 1.9.x` onwards.

      $ juliaup add 1.9.4
      $ juliaup add release

# Add Registry

To make things simpler, this version of the registry is public. To add it to your list, you can use the script `modify_registry.jl` provided above:

```bash
$ julia modify_registry.jl --url https://github.com/isaccnrbo/IsacRegistry add
```

To remove the registry, you can run the command:

```bash
$ julia modify_registry.jl --name IsacRegistry remove
```

You can find more detailed instructions on how to use the script by running: 

```bash
$ julia --help
```

# Download Private packages

All the member of the group should be able to automatically download the required packages on their system. If you have any problems,
you can try to force Julia to use `git` to download the packages instead of `libgit2` as it is used by default:

```bash
julia -e 'ENV["JULIA_PKG_USE_CLI_GIT"]=true'
```

If the problem persists, submit an issue.

# See Also
- [Julia Documentation](https://docs.julialang.org/en/v1/)
- [JuliaGeo](https://juliageo.org/): manipulation of geospatial geometry data
- [JuliaClimate](https://github.com/JuliaClimate):  visualization of climate datasets
- [JuliaFold](https://juliafolds.github.io/data-parallelism/tutorials/quick-introduction/): Data-parallelism using compression and reduction (often faster than loops)
- [Diffences with Python/Matlab/C](https://docs.julialang.org/en/v1/manual/noteworthy-differences/#Noteworthy-differences-from-Python)
- [Wrapping Python code to use in Julia](https://github.com/JuliaPy/PyCall.jl)



