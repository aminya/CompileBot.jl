using Documenter
using CompileBot

makedocs(
    modules=[CompileBot],
    authors="Amin Yahyaabadi",
    repo="https://github.com/aminya/CompileBot.jl/blob/{commit}{path}#L{line}",
    sitename="CompileBot.jl",
    format=Documenter.HTML(;
        prettyurls = prettyurls = get(ENV, "CI", nothing) == "true",
        # canonical="https://aminya.github.io/CompileBot.jl",
        # assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Syntax Reference" => "reference.md"
    ],
)

deploydocs(
    repo = "github.com/aminya/CompileBot.jl.git",
    push_preview=true
)
