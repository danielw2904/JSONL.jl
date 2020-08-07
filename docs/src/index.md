```@meta
CurrentModule = JSONL
```

# JSONL

A simple package to read (parts of) a [JSON Lines](http://jsonlines.org/) files to a DataFrame. It currently only exports one function [`readfile(file::AbstractString; kwargs...)`](@ref) which allows memory-efficient loading of rows of a JSON Lines file. In order to select the rows `skip` and `nrows` can be used to load `nrows` rows after skipping `skip` rows. The file is `mmap`ed and only the required rows are loaded into RAM. Files must contain a valid JSON object (denoted by `{"String1":ELEMENT1, "String2":ELEMENT2, ...}`) on each line. JSON parsing is done using the [LazyJSON](https://github.com/JuliaCloud/LazyJSON.jl) package. Lines can be separated by `\n` or `\r\n` and some whitespace characters are allowed between the end of the JSON object and the newline character (basically all that can be represented as a single `UInt8`). Typically a file would look like this:

```
{"name":"Daniel","organization":"IMSM"}
{"name":"Peter","organization":"StatMath"}
```

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
