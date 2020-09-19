# SnoopCompileBot

SnoopCompileBot automatically generates precompilation data for your Julia packages, which results in reducing the time it takes for runtime compilation, loading, and startup.

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aminya.github.io/SnoopCompileBot.jl/dev)
![CI](https://github.com/aminya/SnoopCompileBot.jl/workflows/CI/badge.svg)
![workflow_CI](https://github.com/aminya/SnoopCompileBot.jl/workflows/workflow_CI/badge.svg)
[![codecov](https://codecov.io/gh/aminya/SnoopCompileBot.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/aminya/SnoopCompileBot.jl)

# Installation and Usage
```julia
using Pkg
Pkg.add("SnoopCompileBot")
```
```julia
using SnoopCompileBot
```

# Documentation
Click on the badge: [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aminya.github.io/SnoopCompileBot.jl/dev)

**Notice**: SnoopCompileBot is now in a separate repository, and the API is changed because of that. Call `using SnoopCompileBot` directly in your snoop scripts and update your workflow based on this guide: [Configure the bot to run with a GitHub Action file]( https://aminya.github.io/SnoopCompileBot.jl/dev/#Configure-the-bot-to-run-with-a-GitHub-Action-file-1)


# Projects using SnoopCompileBot:
- [Plots](https://github.com/JuliaPlots/Plots.jl)
