using JuliaFormatter
function postprocess()

  if get(ENV, "GITHUB_ACTIONS", "false") == "true"

    # TODO rewrite using Julia functions

    # Move the content of the directory to the root
    run(`rsync -a artifact/\* ./`)
    run(`rm -d -r artifact`)

    # Discard unrelated changes
    run(`test -f 'Project.toml' \&\& git checkout -- 'Project.toml'`)
    run(`git ls-files 'Manifest.toml' \| grep . \&\& git checkout -- 'Manifest.toml'`)

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
