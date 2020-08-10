module JSONL

import JSON3, 
    Mmap

export readfile

include("helpers.jl")

"""
    readfile(file::AbstractString; kwargs...) => Vector{JSON3.Object}

Read (parts of) a JSONLines file.

* `file`: Path to JSONLines file
* Keyword Arguments:
    * `structtype = nothing`
    * `promotecols::Bool = false`: Promote columns to Float64, Int64 or String
    * `nrows = nothing`: Number of rows to load
    * `skip = nothing`: Number of rows to skip before loading
    * `usemmap::Bool = (nrows !== nothing || skip !=nothing)`: Memory map file (required for nrows and skip)
"""
function readfile(file; structtype = nothing, promotecols::Bool = false, nrows = nothing, skip = nothing, usemmap::Bool = (nrows !== nothing || skip !== nothing))
    ff = getfile(file, nrows, skip, usemmap)
    length(ff) == 0 && return JSON3.Object[]
    if isnothing(structtype)
        rows = JSON3.read.(lstrip.(String.(ff)))
    else
        rows = JSON3.read.(lstrip.(String.(ff)), structtype)
    end
    return rows
end

end
