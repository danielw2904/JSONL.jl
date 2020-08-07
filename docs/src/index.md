```@meta
CurrentModule = JSONL
```

# JSONL

A simple package to read (parts of) a [JSON Lines](http://jsonlines.org/) files to a DataFrame. It currently only exports one function [`readfile(file::AbstractString; kwargs...)`](@ref) which allows memory-efficient loading of rows of a JSON Lines file. In order to select the rows `skip` and `nrows` can be used to load `nrows` rows after skipping `skip` rows. The file is `mmap`ed and only the required rows are loaded into RAM. 

# Getting Started

This package is not yet registered but you can add it from GitHub:

```julia-repl
(@v1.5) pkg> add https://github.com/danielw2904/JSONL.jl
```
# Function

```@index
```

```@autodocs
Modules = [JSONL]
```
