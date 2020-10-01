using CompileBot

println("tests infer benchmark")

snoop_bench(BotConfig("TestPackage2", tmin =0.0))
