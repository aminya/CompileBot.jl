# CompileBot.jl

CompileBot automatically generates precompilation data for your Julia packages, which results in reducing the time it takes for runtime compilation, loading, and startup.

# Installation
```julia
using Pkg
Pkg.add("CompileBot")
```
```julia
using CompileBot
```


### Usage

As you change the code in your package, the precompile statements likely need to be updated too.
You can use SnoopCompile bot to automatically and continuously create precompile files.
This bot can be used offline or online.

Follow these steps to set up SnoopCompile bot for your package.

## 1 - Add Julia to your system PATH (if you haven't done that already)

The CompileBot spawns a new Julia process when running the `snoop_bot` function. Therefore, you need to make sure that Julia is added to your system PATH. See the official documentation on how to do that: https://julialang.org/downloads/platform/. To test whether Julia has been added successfully, simply open a terminal and type in `julia`. If everything has been configured correctly, the Julia REPL should be invoked now.

## 2 - Setting up the SnoopCompile bot configuration folder

Here, we will configure the bot in a directory `deps/SnoopCompile/` that should be added to your repository.
All configuration files for the SnoopCompile bot should go in this directory.
If you choose a different name for this directory, be sure to change the path in the configuration steps below.

## 3 - Create the precompile script

You will need a [precompile script](@ref pcscripts), here called `example_script.jl`, that "exercises" the functionality you'd like to precompile.
If you write a dedicated precompile script, place it in the bot configuration folder.

Alternatively, you may use your package's `"runtests.jl"` file.
While less precise about which functionality is worthy of precompilation,
this can slightly simplify configuration as described below.

## 4 - Create the script that runs `snoop_bot`

The `snoop_bot` function generates precompile statements and writes them to
a file that will be incorporated into your package.
`snoop_bot` requires a few settings, which can be most easily generated by [`BotConfig`](@ref).
The script that runs `snoop_bot` should be saved in your configuration directory,
with a name like `snoop_bot.jl`.

The example below (from [here](https://github.com/aminya/Zygote.jl/blob/SnoopCompile/deps/SnoopCompile/snoop_bot.jl)) supports multiple operating systems, multiple Julia versions, and excludes a function whose precompilation would be problematic:

```julia
using CompileBot

botconfig = BotConfig(
  "Zygote";                            # package name (the one this configuration lives in)
  yml_path = "SnoopCompile.yml"        # parse `os` and `version` from `SnoopCompile.yml`
  exclusions = ["SqEuclidean"],        # exclude functions (by name) that would be problematic if precompiled
)

snoop_bot(
  botconfig,
  "$(@__DIR__)/example_script.jl",
)
```

If you choose to use your "runtests.jl" file as your precompile script, configuration can be as simple as specifying just the name of the package:

```julia
using CompileBot

snoop_bot(BotConfig("MyPackage"))
```

!!! note
    Some of your regular tests may not be appropriate for `snoop_bot`.
    `snoop_bot` sets a global variable `SnoopCompile_ENV` to `true` during snooping,
    and sets it to `false` when finished.
    You can exploit this in your tests to determine whether snooping is on:

    ```julia
    if !isdefined(Main, :SnoopCompile_ENV) || SnoopCompile_ENV == false
        # Tests that you want to skip when snooping
    end
    ```

Finally, you could use package loading as the only operation,
with `snoop_bot(config, :(using MyPackage))`.

`snoop_bot` uses different strategies depending on the Julia version:

- On Julia 1.2 or higher, it identifies methods for precompilation based on [`@snoopi`](@ref macro-snoopi);
- On Julia 1.0 or 1.1 (which do not support `@snoopi`), it identifies methods for precompilation based on [`@snoopc`](@ref macro-snoopc).

You can override this default behavior with a keyword argument, see [`snoop_bot`](@ref) for details.

## 5 - Optionally test the impact of your precompiles with `snoop_bench`

Call [`snoop_bench`](@ref) to measure the effect of adding precompile files.
It takes the same parameters as `snoop_bot` above.
You can run this manually, or choose to run it during automatic precompile file generation.
To perform it automatically, create a `snoop_bench.jl` script in the bot configuration directory.
This should be nearly identical to your `snoop_bot.jl` file, but calling `snoop_bench`
instead.
Note that benchmarking has the option of different performance metrics,
`snoop_mode=:snoopi` or `snoop_mode=:run_time` depending on whether you want to measure inference time or the run time of your precompile script.

## 6 - Configure the bot to run with a GitHub Action file

You can create the precompile files automatically when you merge pull requests to `master` by adding a workflow file under `.github/workflows/SnoopCompile.yml`.
This file should have content such as the example below.
Lines marked with `NOTE` deserve special attention as likely places you may
need to adjust the configuration.

```yaml
name: SnoopCompile

on:
  push:
    branches:
    #  - 'master'  # NOTE: uncomment to run the bot only on pushes to master

defaults:
  run:
    shell: bash

jobs:
  SnoopCompile:
    if: "!contains(github.event.head_commit.message, '[skip ci]')"
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false

      matrix:
        # NOTE: only keep the versions you want to support
        # NOTE: if not using `yml_path`, these should match the version in `BotConfig`
        version:
          - 'nightly'
          - '1.5.3'
          - '1.4.2'
          - '1.3.1'
          - '1.2.0'
          - '1.1.1'
          - '1.0.5'
        os:        # NOTE: if not using `yml_path`, these should match the os in `BotConfig`
          - ubuntu-latest
          - windows-latest
          - macos-latest
        arch:
          - x64

    steps:
      - uses: actions/checkout@v2
      - uses: julia-actions/setup-julia@latest
        with:
          version: ${{ matrix.version }}

      - name: Install dependencies
        run: |
          julia --project -e 'using Pkg; Pkg.instantiate();'
          julia -e 'using Pkg; Pkg.add( PackageSpec(name="CompileBot", version = "1") );
                    Pkg.develop(PackageSpec(; path=pwd()));
                    using CompileBot; CompileBot.addtestdep();'

      - name: Generating precompile files
        run: julia --project -e 'include("deps/SnoopCompile/snoop_bot.jl")'   # NOTE: notice the path

      - name: Running Benchmark
        run: julia --project -e 'include("deps/SnoopCompile/snoop_bench.jl")' # NOTE: optional, if have benchmark file

      - name: Upload all
        continue-on-error: true # due to connection issues
        uses: actions/upload-artifact@v2.0.1
        with:
          path: ./

  Create_PR:
    if: "!contains(github.event.head_commit.message, '[skip ci]')"
    needs: SnoopCompile
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Download all
        uses: actions/download-artifact@v2

      - name: CompileBot postprocess
        run: julia -e 'using Pkg; Pkg.add( PackageSpec(name="CompileBot", version = "1") );
                       using CompileBot; CompileBot.postprocess();'

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: Update precompile_*.jl file
          title: "[AUTO] Update precompiles"
          labels: SnoopCompile
          branch: "SnoopCompile_AutoPR_${{ github.ref }}"


  Skip:
    if: "contains(github.event.head_commit.message, '[skip ci]')"
    runs-on: ubuntu-latest
    steps:
      - name: Skip CI 🚫
        run: echo skip ci
```

You can learn more about these files and the workflow process in the [documentation](https://help.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow).
Examples of such files in projects can be found in other packages, for example
[Zygote](https://github.com/aminya/Zygote.jl/blob/SnoopCompile/.github/workflows/SnoopCompile.yml).


!!! note

    Upgrading from an old SnoopCompile bot:

    CompileBot is now in a separate repository, and the API is changed because of that. Call `using CompileBot` directly in your snoop scripts and update your workflow based on this guide: [Configure the bot to run with a GitHub Action file]( https://aminya.github.io/CompileBot.jl/dev/#Configure-the-bot-to-run-with-a-GitHub-Action-file-1)

    In addition to the previous steps, you should also remove `_precompile_()` and any other code that includes a `_precompile_()` function. In the new version, SnoopCompile automatically creates the appropriate code.
