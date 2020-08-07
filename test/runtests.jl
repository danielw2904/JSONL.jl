using JSONL
using Test, DataFrames, RDatasets

full_web = readfile("testfiles/jsonlwebsite.jsonl")
nrow_fw = nrow(full_web)

mtcars = dataset("datasets", "mtcars")
full_mtcars = readfile("testfiles/mtcars.jsonl", promotecols = true);
# Fix R export differences
rename!(full_mtcars, :_row => :model);
rename!(full_mtcars, names(full_mtcars) .=> lowercase.(names(full_mtcars)))
rename!(mtcars, names(mtcars) .=> lowercase.(names(mtcars)))

# Read without promotion
noprom_mtcars = readfile("testfiles/mtcars.jsonl")
nrow_mt = nrow(mtcars)

oneline = readfile("testfiles/oneline.jsonl")
oneline_plus = readfile("testfiles/oneline_plus.jsonl")

escaped = readfile("testfiles/escapedeol.jsonl")

@testset "Read" begin
    @test full_web.name == ["Gilbert", "Alexa", "May", "Deloise"]
    @test full_web.wins[1] == [["straight", "7♣"], ["one pair", "10♥"]]
    @test full_web.wins[end] == [["three of a kind", "5♣"]] 
    @test full_mtcars.mpg == mtcars.mpg
    @test noprom_mtcars.cyl[32] == 4
    @test noprom_mtcars.wt[30] == 2.77
    @test noprom_mtcars.qsec[16] == 17.82
    @test noprom_mtcars[!, :_row][16] == "Lincoln Continental"
    @test noprom_mtcars[!, :drat] == mtcars[!, :drat]
    @test oneline.name == ["Daniel"]
    @test oneline_plus.name == ["Daniel"]
    @test nrow(escaped) == 4
    @test escaped.name[1] == "Daniel\n"
    @test escaped.age[2] == "}"
end

@testset "Mmap Full File" begin
# full file equal
    @test readfile("testfiles/jsonlwebsite.jsonl", usemmap = true) == full_web
    @test readfile("testfiles/mtcars.jsonl", usemmap = true) == noprom_mtcars
    @test readfile("testfiles/oneline.jsonl", usemmap = true) == oneline
    @test readfile("testfiles/oneline_plus.jsonl", usemmap = true) == oneline_plus
    @test readfile("testfiles/escapedeol.jsonl", usemmap = true) == escaped
end

@testset "skip & nrows" begin
# skip + nrows = nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = 1, nrows = nrow_fw-1) == full_web[2:end, :]
    @test readfile("testfiles/mtcars.jsonl", skip = 2, nrows = nrow_mt-2) == noprom_mtcars[3:end, :]

# skip + nrows < nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = 1, nrows = 2) == full_web[2:3, :]
    @test readfile("testfiles/mtcars.jsonl", skip = 2, nrows = 2) == noprom_mtcars[3:4, :]
    @test readfile("testfiles/escapedeol.jsonl", skip = 2, nrows = 1) == escaped[3:3, :]

# skip + nrows > nrow(file) (through nrow)
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = 1, nrows = nrow_fw) == full_web[2:end, :]
    @test readfile("testfiles/mtcars.jsonl", skip = 12, nrows = nrow_mt + 10) == noprom_mtcars[13:end, :]
    @test readfile("testfiles/oneline.jsonl", skip = 0, nrows = 5) == oneline
    @test readfile("testfiles/oneline_plus.jsonl", skip = 0, nrows = 2) == oneline_plus
    @test readfile("testfiles/escapedeol.jsonl", skip = 2, nrows = 10) == escaped[3:end, :]

# skip + nrows > nrow(file) (through skip)
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = nrow_fw+1, nrows = 1) == DataFrame()
    @test readfile("testfiles/mtcars.jsonl", skip = nrow_mt +12, nrows = 120) ==  DataFrame()
    @test readfile("testfiles/oneline.jsonl", skip = 2, nrows = 10) == DataFrame()
    @test readfile("testfiles/oneline_plus.jsonl", skip = 2, nrows = 123) == DataFrame()
    @test readfile("testfiles/escapedeol.jsonl", skip = 5, nrows = 1) == DataFrame()

# skip = nrow(file) + nrows > 0
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = nrow_fw, nrows = 10) == DataFrame()
    @test readfile("testfiles/mtcars.jsonl", skip = nrow_mt, nrows = 1) == DataFrame()
    @test readfile("testfiles/oneline.jsonl", skip = 1, nrows = 12) == DataFrame()
    @test readfile("testfiles/oneline_plus.jsonl", skip = 1, nrows = 1) == DataFrame()
    @test readfile("testfiles/escapedeol.jsonl", skip = 4, nrows = 1) == DataFrame()
end

@testset "skip" begin
# skip = nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = nrow_fw) == DataFrame()
    @test readfile("testfiles/mtcars.jsonl", skip = nrow_mt) == DataFrame()
    @test readfile("testfiles/oneline.jsonl", skip = 1) == DataFrame()
    @test readfile("testfiles/oneline_plus.jsonl", skip = 1) == DataFrame()
    @test readfile("testfiles/escapedeol.jsonl", skip = 4) == DataFrame()

# skip > nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = nrow_fw + 1) == DataFrame()
    @test readfile("testfiles/mtcars.jsonl", skip = nrow_mt + 42) == DataFrame()
    @test readfile("testfiles/mtcars.jsonl", skip = typemax(Int)) == DataFrame()
    @test readfile("testfiles/oneline.jsonl", skip = 2) == DataFrame()
    @test readfile("testfiles/oneline_plus.jsonl", skip = 2) == DataFrame()
    @test readfile("testfiles/escapedeol.jsonl", skip = 5) == DataFrame()
    
# skip < nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", skip = nrow_fw - 1) == full_web[end:end, :]
    @test readfile("testfiles/mtcars.jsonl", skip = nrow_mt - 12) == noprom_mtcars[(end-11):end, :]
    @test readfile("testfiles/escapedeol.jsonl", skip = 2) == escaped[3:end, :]
end

@testset "nrows" begin
# nrows < nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", nrows = 2) == full_web[begin:2, :]
    @test readfile("testfiles/mtcars.jsonl", nrows = 12) == noprom_mtcars[begin:12, :]
    @test readfile("testfiles/escapedeol.jsonl", nrows = 3) == escaped[begin:3, :]

# nrows = nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", nrows = nrow_fw) == full_web
    @test readfile("testfiles/mtcars.jsonl", nrows = nrow_mt) == noprom_mtcars
    @test readfile("testfiles/oneline.jsonl", nrows = 1) == oneline
    @test readfile("testfiles/oneline_plus.jsonl", nrows = 1) == oneline_plus
    @test readfile("testfiles/escapedeol.jsonl", nrows = 4) == escaped

# nrows > nrow(file)
    @test readfile("testfiles/jsonlwebsite.jsonl", nrows = nrow_fw+1) == full_web
    @test readfile("testfiles/mtcars.jsonl", nrows = nrow_mt+100) == noprom_mtcars
    @test readfile("testfiles/oneline.jsonl", nrows = 2) == oneline
    @test readfile("testfiles/oneline_plus.jsonl", nrows = 2) == oneline_plus
    @test readfile("testfiles/escapedeol.jsonl", nrows = 5) == escaped
end