const _LSEP = UInt8('\n')
const _EOL = UInt8('}')
const _BOL = UInt8('{')
const _ESC = UInt8('\\') 
const _INT_MAX = typemax(Int)
const _SPLT = Sys.iswindows() ? "\r\n" : '\n'

function getfile(file, nlines, skip, usemmap)
    if usemmap
        nlines === nothing && (nlines = _INT_MAX)
        skip === nothing && (skip = 0)
        ff = mmapstr(file, nlines, skip)
    else
        nlines !== nothing || skip !== nothing && @warn "nlines and skip require mmap. Returning all lines."
        ff = readstr(file)
    end
    return ff
end

function readstr(file)
    fi = read(file);
    out = split(String(fi), _SPLT, keepempty = false);
    return out
end

function detecteol(fi, cur)
    cur = findnext(isequal(_EOL), fi, nextind(fi, cur))
    return findnext(isequal(_LSEP), fi, cur)
end

function mmapstr(file, nlines::Int, skip::Int)
    @assert nlines > 0 "nlines must be positive"
    fi = Mmap.mmap(file);
    len = length(fi)
    skip > len && (return SubString{String}[])
    cur = detecteol(fi, firstindex(fi))
    if skip == 0
        start = firstindex(fi)
        if cur == len || cur === nothing 
            return SubString{String}[String(fi)]
        end
    elseif skip > 0
        if cur == len || cur === nothing
            return SubString{String}[]
        end
        for _ in 2:skip 
            cur = detecteol(fi, cur)
            if cur == len || cur === nothing 
                return SubString{String}[]
            end
        end
        start = nextind(fi, cur)
        cur = detecteol(fi, cur)
        if cur == len || cur === nothing
            return SubString{String}[String(fi[start:lastindex(fi)])]
        end
    else
        start = firstindex(fi)
        @warn "Ignoring skip value: $skip"
    end

    nlines === _INT_MAX && (return split(String(fi[start:lastindex(fi)]), _SPLT, keepempty = false))
    nlines == 1 && (return SubString{String}[String(fi[start:prevind(fi, cur)])])

    if cur < len 
        for _ in 2:nlines
            cur = detecteol(fi, cur)
            # cur = findnext(isequal(_LSEP), fi, nextind(fi, cur))
            if cur == len || cur === nothing
                return split(String(fi[start:lastindex(fi)]), _SPLT, keepempty = false)
            end #if 
        end #for 
    end #if 
    out = split(String(fi[start:prevind(fi, cur)]), _SPLT, keepempty = false)
    return out
end

function makedf(coliter, names)
    df = DataFrame()
    for (i, col) in enumerate(coliter)
        df[!, names[i]] = col
    end
    return df
end

function colpromote!(df)
    numcols =  findall(col -> isa(col, Array{<:Number}), eachcol(df))
    strcols = findall(col -> isa(col, Array{<:AbstractString}), eachcol(df))
    for numcol in numcols
        df[!, numcol] = convert.(Float64, df[!, numcol])::Array{Float64,1}
        try
            df[!, numcol] = convert.(Int64, df[!, numcol])::Array{Int64, 1}
        catch
        end
    end
    for strcol in strcols
        df[!, strcol] = convert.(String, df[!, strcol])::Array{String,1}
    end
    return nothing
end
