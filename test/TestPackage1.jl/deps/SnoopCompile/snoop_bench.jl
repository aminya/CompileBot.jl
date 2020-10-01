using CompileBot

println("tests infer benchmark")

snoop_bench(BotConfig("TestPackage1", tmin =0.0))
