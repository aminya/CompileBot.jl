using SnoopCompileBot

println("tests infer benchmark")

snoop_bench(BotConfig("TestPackage0", tmin =0.0))
