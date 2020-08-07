using JSONL
using Documenter

makedocs(;
    modules=[JSONL],
    authors="Daniel Winkler <danielw2904@disroot.org> and contributors",
    repo="https://github.com/danielw2904/JSONL.jl/blob/{commit}{path}#L{line}",
    sitename="JSONL.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://danielw2904.github.io/JSONL.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/danielw2904/JSONL.jl",
)
