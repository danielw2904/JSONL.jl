module JSONL

using DataFrames
import LazyJSON,
    Mmap

export readfile

include("helpers.jl")

"""
    readfile(file::AbstractString; kwargs...) => DataFrames.DataFrame()

Read (parts of) a JSONLines file.

* `file`: Path to JSONLines file
* Keyword Arguments:
    * `promotecols::Bool = false`: Promote columns to Float64, Int64 or String
    * `nrows = nothing`: Number of rows to load
    * `skip = nothing`: Number of rows to skip before loading
    * `usemmap::Bool = (nrows !== nothing || skip !=nothing)`: Memory map file (required for nrows and skip)
"""
function readfile(file; promotecols::Bool = false, nrows = nothing, skip = nothing, usemmap::Bool = (nrows !== nothing || skip !== nothing))
    ff = getfile(file, nrows, skip, usemmap)
    Sys.iswindows() && filter!(!isequal("\r"), ff)
    length(ff) == 0 && return DataFrame()
    rows::Array{LazyJSON.Object{Nothing, String} ,1} = LazyJSON.value.(ff)
    colnames::Vector{String} = String.(keys(first(rows)))
    cols = ([row[col] for row in rows] for col in colnames)
    df = makedf(cols, colnames)
    promotecols && colpromote!(df)
    return df
end

end
