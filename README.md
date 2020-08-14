# SnoopCompileBot

SnoopCompileBot automatically generates precompilation data for your Julia packages, which results in reducing the time it takes for runtime compilation, loading, and startup.

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aminya.github.io/SnoopCompileBot.jl/dev)
![Build Status (Github Actions)](https://github.com/aminya/SnoopCompileBot.jl/workflows/CI/badge.svg)

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

**Notice**: SnoopCompileBot is now in a separate repository, and the GitHubActions API is changed because of that. Update your workflow based on this guide: [Configure the bot to run with a GitHub Action file]( https://aminya.github.io/SnoopCompileBot.jl/dev/#Configure-the-bot-to-run-with-a-GitHub-Action-file-1)
