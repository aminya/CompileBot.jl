using JuliaFormatter
function postprocess()

  if get(ENV, "GITHUB_ACTIONS", "false") == "true"

    # TODO rewrite using Julia functions

    # Move the content of the directory to the root
    artifact_path =joinpath(pwd(), "artifact")
    run(`rsync -a $artifact_path/ ./`)
    run(`rm -d -r $artifact_path`)

    # Discard unrelated changes
    Projecttoml_path =joinpath(pwd(), "Project.toml")
    if isfile(Projecttoml_path)
      run(`git checkout -- $Projecttoml_path`)
    end

    # Julia doesn't support &&
    # Manifesttoml_path =joinpath(pwd(), "Manifest.toml")
    # run(`git ls-files  $Manifesttoml_path \| grep . \&\& git checkout --  $Manifesttoml_path`)

    # BUG causes issues
    # run(`(git diff -w --no-color || git apply --cached --ignore-whitespace && git checkout -- . && git reset && git add -p) || echo done`)

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
