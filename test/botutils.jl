@testset "pathof_noload" begin
    pnl = CompileBot.pathof_noload("Example")
    import Example
    p = GoodPath(pathof(Example))
    @test p == pnl
end

################################################################

@testset "detectOS" begin
    if Base.Sys.iswindows()
        @test ("windows", Base.Sys.iswindows) == CompileBot.detectOS()
    elseif Base.Sys.islinux()
        @test ("linux", Base.Sys.islinux) == CompileBot.detectOS()
    elseif Base.Sys.isapple()
        @test ("apple", Base.Sys.isapple) == CompileBot.detectOS()
    end
end
################################################################
# JuliaVersionNumber

# https://github.com/JuliaLang/julia/pull/36223:
# @test CompileBot.JuliaVersionNumber("nightly") ==
      # VersionNumber(replace(Base.read("VERSION", String), "\n" => ""))
# @test thispatch(CompileBot.JuliaVersionNumber("nightly")) == thispatch(VERSION)
@test CompileBot.JuliaVersionNumber("1.2.3") == v"1.2.3"
@test CompileBot.JuliaVersionNumber(v"1.2.3") == v"1.2.3"
