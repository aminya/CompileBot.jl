using Documenter
using SnoopCompileBot

makedocs(
    modules=[SnoopCompileBot],
    authors="Amin Yahyaabadi",
    repo="https://github.com/aminya/SnoopCompileBot.jl/blob/{commit}{path}#L{line}",
    sitename="SnoopCompileBot.jl",
    format=Documenter.HTML(;
        prettyurls = prettyurls = get(ENV, "CI", nothing) == "true",
        # canonical="https://aminya.github.io/SnoopCompileBot.jl",
        # assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Syntax Reference" => "reference.md"
    ],
)

deploydocs(
    repo = "github.com/aminya/SnoopCompileBot.jl.git",
    push_preview=true
)
