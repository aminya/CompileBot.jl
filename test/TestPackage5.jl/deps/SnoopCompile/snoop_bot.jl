using CompileBot

bcs = Vector{BotConfig}(undef, 3)

bcs[1] = BotConfig("TestPackage5", yml_path = "SnoopCompile.yml", tmin =0.0)

bcs[2] = BotConfig("TestPackage5", yml_path = "../../.github/workflows/SnoopCompile.yml", tmin =0.0)

bcs[3] = BotConfig("TestPackage5", yml_path = ".github/workflows/SnoopCompile.yml", tmin =0.0)

if !( VERSION <= v"1.2" && Base.Sys.iswindows() )
    push!(bcs, BotConfig("TestPackage5", yml_path = "../../$(@__DIR__)/.github/workflows/SnoopCompile.yml", tmin =0.0))
end
