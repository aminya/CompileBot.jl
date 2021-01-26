using CompileBot, Test
import CompileBot.goodjoinpath
stripall(x::String) = replace(x, r"\s|\n"=>"")

snoopcompiledir = pwd()
bottestdir = GoodPath(@__DIR__)

@testset "bot" begin

    @testset "add_includer" begin
        package_name = "TestPackage0"
        package_path = goodjoinpath(bottestdir,"$package_name.jl","src","$package_name.jl")
        includer_path = goodjoinpath(dirname(package_path), "precompile_includer.jl")

        CompileBot.add_includer(package_name, package_path)

        @test occursin("include(\"precompile_includer.jl\")", stripall(Base.read(package_path, String)))
    end

    @testset "precompile de/activation" begin
        package_name = "TestPackage0"
        package_path = goodjoinpath(bottestdir,"$package_name.jl","src","$package_name.jl")
        precompiles_rootpath = goodjoinpath(bottestdir,"$package_name.jl","deps/SnoopCompile/precompile")
        includer_path = goodjoinpath(dirname(package_path), "precompile_includer.jl")

        CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, nothing, nothing, nothing, nothing)

        CompileBot.precompile_deactivator(package_path)
        @test occursin("should_precompile=false", stripall(Base.read(includer_path, String)))

        CompileBot.precompile_activator(package_path)
        includer_text = stripall(Base.read(includer_path, String))
        @test occursin("should_precompile=true", includer_text)

        rm(includer_path)
    end

    @testset "precompile new_includer_file" begin
        package_name = "TestPackage0"
        package_path = goodjoinpath(bottestdir,"$package_name.jl","src","$package_name.jl")
        precompiles_rootpath = "$(dirname(dirname(package_path)))/deps/SnoopCompile/precompile"
        precompiles_rootpath_rel = GoodPath(relpath( precompiles_rootpath , dirname(package_path)))
        includer_path = goodjoinpath(dirname(package_path), "precompile_includer.jl")


        @testset "no os, no else_os, no version, no else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, nothing, nothing, nothing, nothing)
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=false", includer_text)
            @test occursin("ismultiversion=false", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else

            end # precompile_enclosure
            """), includer_text)
        end

        @testset "yes os, no else_os, no version, no else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, ["linux", "windows"], nothing, nothing, nothing)
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=true", includer_text)
            @test occursin("ismultiversion=false", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else
                @static if Sys.islinux()
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel/linux/precompile_$package_name.jl")
                        _precompile_()
                    end
                elseif Sys.iswindows()
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel/windows/precompile_$package_name.jl")
                        _precompile_()
                    end
                else
                end

            end
            """), includer_text)
        end

        @testset "yes os, yes else_os, no version, no else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, ["linux", "windows"], "linux", nothing, nothing)
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=true", includer_text)
            @test occursin("ismultiversion=false", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else
                @static if Sys.islinux()
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel/linux/precompile_$package_name.jl")
                        _precompile_()
                    end
                elseif Sys.iswindows()
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel/windows/precompile_$package_name.jl")
                        _precompile_()
                    end
                else
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel/linux/precompile_$package_name.jl")
                        _precompile_()
                    end
                end

            end # precompile_enclosure
            """), includer_text)
        end

        @testset "no os, no else_os, yes version, no else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, nothing, nothing, [v"1.2",v"1.5.0"], nothing)
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=false", includer_text)
            @test occursin("ismultiversion=true", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else
                @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel//1.2/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel//1.2/precompile_$package_name.jl")
                        _precompile_()
                    end
                elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel//1.5/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel//1.5/precompile_$package_name.jl")
                        _precompile_()
                    end
                else
                end

            end # precompile_enclosure
            """), includer_text)
        end


        @testset "no os, no else_os, yes version, yes else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, nothing, nothing, [v"1.2",v"1.5.0"],v"1.5.0")
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=false", includer_text)
            @test occursin("ismultiversion=true", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else
                @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel//1.2/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel//1.2/precompile_$package_name.jl")
                        _precompile_()
                    end
                elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel//1.5/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel//1.5/precompile_$package_name.jl")
                        _precompile_()
                    end
                else
                    @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel//1.5/precompile_$package_name.jl"))
                        include("$precompiles_rootpath_rel//1.5/precompile_$package_name.jl")
                        _precompile_()
                    end
                end

            end # precompile_enclosure
            """), includer_text)
        end

        @testset "yes os, yes else_os, yes version, no else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, ["linux", "windows"], "linux", [v"1.2",v"1.5.0"], nothing)
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=true", includer_text)
            @test occursin("ismultiversion=true", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else
                @static if Sys.islinux()
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                    end

                elseif Sys.iswindows()
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/windows/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                    end

                else
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                    end

                end

            end # precompile_enclosure
            """), includer_text)
        end

        @testset "yes os, yes else_os, yes version, yes else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, ["linux", "windows"], "linux", [v"1.2",v"1.5.0"],v"1.5.0")
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=true", includer_text)
            @test occursin("ismultiversion=true", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else
                @static if Sys.islinux()
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    end

                elseif Sys.iswindows()
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/windows/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    end

                else
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    end

                end

            end # precompile_enclosure
            """), includer_text)
        end

        @testset "yes os, no else_os, yes version, no else_version" begin
            CompileBot.new_includer_file(package_name, package_path, precompiles_rootpath, ["linux", "windows"], nothing, [v"1.2",v"1.5.0"], nothing)
            includer_text = stripall(Base.read(includer_path, String))
            @test occursin("ismultios=true", includer_text)
            @test occursin("ismultiversion=true", includer_text)

            @test occursin(stripall("""
            @static if !should_precompile
                # nothing
            elseif !ismultios && !ismultiversion
                @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/precompile_$package_name.jl"))
                    include("$precompiles_rootpath_rel/precompile_$package_name.jl")
                    _precompile_()
                end
            else
                @static if Sys.islinux()
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/linux/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                    end

                elseif Sys.iswindows()
                    @static if v"1.2.0-DEV" <= VERSION <= v"1.2.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/1.2/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/windows/1.2/precompile_$package_name.jl")
                            _precompile_()
                        end
                    elseif v"1.5.0-DEV" <= VERSION <= v"1.5.9"
                        @static if isfile(joinpath(@__DIR__, "$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl"))
                            include("$precompiles_rootpath_rel/windows/1.5/precompile_$package_name.jl")
                            _precompile_()
                        end
                    else
                    end

                else
                end

            end # precompile_enclosure
            """), includer_text)
        end
        rm(includer_path)
    end



    using Pkg
    package_rootpath = String[]
    for (i, package_name) in enumerate(["TestPackage1", "TestPackage2", "TestPackage3", "TestPackage0", "TestPackage5"])
        Pkg.develop(PackageSpec(path=joinpath(bottestdir,"$package_name.jl")))
        push!(package_rootpath, goodjoinpath(bottestdir,"$package_name.jl"))
    end
    @show package_rootpath

    @testset "snoop_bot" begin

        include("$(package_rootpath[1])/deps/SnoopCompile/snoop_bot.jl")

        @test isfile("$(package_rootpath[1])/deps/SnoopCompile/precompile/precompile_TestPackage1.jl")

        @test isfile("$(package_rootpath[1])/.gitattributes")
        rm("$(package_rootpath[1])/.gitattributes", force=true)

        precompile_text = Base.read("$(package_rootpath[1])/deps/SnoopCompile/precompile/precompile_TestPackage1.jl", String)

        @test occursin("hello", precompile_text)
        @test occursin("domath", precompile_text)
    end

    @testset "snoop_bench" begin
        include("$(package_rootpath[1])/deps/SnoopCompile/snoop_bench.jl")
    end

    @testset "snoop_bot_multios" begin
        os, osfun = CompileBot.detectOS()

        include("$(package_rootpath[2])/deps/SnoopCompile/snoop_bot.jl")

        @test isfile("$(package_rootpath[2])/.gitattributes")
        rm("$(package_rootpath[2])/.gitattributes", force=true)

        @test isfile("$(package_rootpath[2])/deps/SnoopCompile/precompile/$os/precompile_TestPackage2.jl")

        precompile_text = Base.read("$(package_rootpath[2])/deps/SnoopCompile/precompile/$os/precompile_TestPackage2.jl", String)

        if os == "windows"
            @test occursin("hello2", precompile_text)
            @test !occursin("domath2", precompile_text)
        else
            @test !occursin("hello2", precompile_text)
            @test occursin("domath2", precompile_text)
        end
    end

    @testset "snoop_bench-multios" begin
        include("$(package_rootpath[2])/deps/SnoopCompile/snoop_bench.jl")
    end

    @testset "snoop_bot_multiversion" begin
        os, osfun = CompileBot.detectOS()

        include("$(package_rootpath[3])/deps/SnoopCompile/snoop_bot.jl")

        @test isfile("$(package_rootpath[3])/.gitattributes")
        rm("$(package_rootpath[3])/.gitattributes", force=true)

        @test isfile("$(package_rootpath[3])/deps/SnoopCompile/precompile/$(CompileBot.VersionFloat(VERSION))/precompile_TestPackage3.jl")

        precompile_text = Base.read("$(package_rootpath[3])/deps/SnoopCompile/precompile/$(CompileBot.VersionFloat(VERSION))/precompile_TestPackage3.jl", String)

        if VERSION > v"1.3"
            @test occursin("hello3", precompile_text)
            @test !occursin("domath3", precompile_text)
            @test !occursin("multiply3", precompile_text)
        elseif VERSION > v"1.2"
            @test !occursin("hello3", precompile_text)
            @test occursin("domath3", precompile_text)
            @test !occursin("multiply3", precompile_text)
        else
            @test !occursin("hello3", precompile_text)
            @test !occursin("domath3", precompile_text)
            @test occursin("multiply3", precompile_text)
        end
    end

    if VERSION <= v"1.5.0"
        @testset "snoop_bench-multiversion" begin
            include("$(package_rootpath[3])/deps/SnoopCompile/snoop_bench.jl")
        end
    else
        @warn "else version is set to 1.2, so we should not run the benchmark test on nightly, when we have not generated such files yet (unlike in the realworld tests)."
    end


    @testset "Nothing is generated" begin

        include("$(package_rootpath[4])/deps/SnoopCompile/snoop_bot.jl")

        @test isfile("$(package_rootpath[4])/deps/SnoopCompile/precompile/precompile_TestPackage0.jl")

        precompile_text = Base.read("$(package_rootpath[4])/deps/SnoopCompile/precompile/precompile_TestPackage0.jl", String)

        @test occursin(stripall("""
        function _precompile_()
            # nothing
        end
        """), stripall(precompile_text))
    end

    @testset "Nothing is generated" begin
        include("$(package_rootpath[4])/deps/SnoopCompile/snoop_bench.jl")
    end

    @testset "yaml os and version parse" begin
        include("$(package_rootpath[5])/deps/SnoopCompile/snoop_bot.jl")
        for bc in bcs
            @test [v"1.5.0", v"1.3.1"] == bc.version
            @test ["ubuntu-latest", "windows-latest", "macos-latest"] == bc.os
        end
    end

    # Clean Test remainder
    for (i, package_name) in enumerate(["TestPackage1", "TestPackage2", "TestPackage3", "TestPackage0", "TestPackage5"])
        Pkg.rm(package_name)
        main_file= goodjoinpath(package_rootpath[i], "src/$package_name.jl")
        run(`git checkout -- $main_file`)
    end
    Pkg.resolve()
    project_toml_path = "$(dirname(bottestdir))/Project.toml"
    run(`git checkout -- $project_toml_path`)

    # just in case
    cd(snoopcompiledir)

    include("botutils.jl")
end
