# CompileBot

CompileBot automatically generates precompilation data for your Julia packages, which results in reducing the time it takes for runtime compilation, loading, and startup.

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aminya.github.io/CompileBot.jl/dev)
![CI](https://github.com/aminya/CompileBot.jl/workflows/CI/badge.svg)
![workflow_CI](https://github.com/aminya/CompileBot.jl/workflows/workflow_CI/badge.svg)
[![codecov](https://codecov.io/gh/aminya/CompileBot.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/aminya/CompileBot.jl)

# Installation and Usage
```julia
using Pkg
Pkg.add("CompileBot")
```
```julia
using CompileBot
```

# Documentation
Click on the badge: [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aminya.github.io/CompileBot.jl/dev)

**Notice**: CompileBot is now in a separate repository, and the API is changed because of that. Call `using CompileBot` directly in your snoop scripts and update your workflow based on this guide: [Configure the bot to run with a GitHub Action file]( https://aminya.github.io/CompileBot.jl/dev/#Configure-the-bot-to-run-with-a-GitHub-Action-file-1)


# Projects that use CompileBot:
- [Plots](https://github.com/JuliaPlots/Plots.jl)
