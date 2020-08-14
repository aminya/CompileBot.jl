using SnoopCompileBot

println("tests infer benchmark")

snoop_bench(BotConfig("TestPackage3", tmin =0.0))
