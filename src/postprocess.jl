using JuliaFormatter
function postprocess()

  if get(ENV, "GITHUB_ACTIONS", "false") == "true"

    # TODO rewrite using Julia functions

    # Move the content of the directory to the root
    artifact_path = joinpath(pwd(), "artifact")
    # remove .git folder
    gitdir = joinpath(artifact_path, ".git")
    if isdir(gitdir)
      rm(gitdir, recursive=true)
    end
    # move and clean
    run(`rsync -a $artifact_path/ ./`)
    rm(artifact_path, recursive=true)

    # Discard unrelated changes
    package_entry_regex = r"src\/[A-Z][^\/]*\.jl"
    precompile_files_regex =  r"precompile\/.*precompile_.*\.jl"
    git_checkout_all([".gitignore", "src/precompile_includer.jl", precompile_files_regex, package_entry_regex], pwd())

    # ignore whitespace
    # last line of src/Package.jl needs to be kept!
    # https://stackoverflow.com/a/49899908/7910299
    try
      diff_file = tempname()
      run(pipeline(
        `git diff --ignore-space-change --ignore-all-space --ignore-blank-lines --ignore-cr-at-eol --ignore-space-at-eol`,
        diff_file,
      ))
      run(`git stash`)
      run(`git apply  --ignore-space-change --ignore-whitespace --whitespace=fix $diff_file`)
    catch
      @warn "The generated PR includes whitespace changes. Please commit the generated .gitattributes to prevent these changes"
      run(`git stash pop`)
    end

    # Format precompile_includer.jl
    format_file(joinpath(pwd(), "src/precompile_includer.jl"))

    # TODO
    # - name: Create Pull Request
    #   # https://github.com/marketplace/actions/create-pull-request
    #   uses: peter-evans/create-pull-request@v2
    #   with:
    #     token: ${{ secrets.GITHUB_TOKEN }}
    #     commit-message: Update precompile_*.jl file
    #     committer: YOUR NAME <yourEmail@something.com> # NOTE: change `committer` to your name and your email.
    #     title: "[AUTO] Update precompiles"
    #     labels: SnoopCompile
    #     branch: "SnoopCompile_AutoPR"

  end

end

using FilePathsBase
"""
  git_checkout_all( ignore_list::Vector, rootpath::AbstractString = pwd()) # <UString

Discard unrelated changes

# Examples
```julia
git_checkout_all(["src/precompile_includer.jl", r"precompile/.*precompile_.*\\.jl"], pwd())
```
"""
function git_checkout_all( ignore_list::Vector, rootpath::AbstractString = pwd(), debug=true) # <UString
  push!(ignore_list, ".git/")
  for file in walkpath(Path(rootpath))
    filepath = GoodPath(string(file))
    if isfile(filepath) && !any(occursin.( ignore_list,  Ref(filepath) ))
      if !isempty(readchomp(`git ls-files $filepath`))
        if debug
          println("running git checkout -- $filepath")
        end
        run(`git checkout -- $filepath`)
      end
    end
  end
end
