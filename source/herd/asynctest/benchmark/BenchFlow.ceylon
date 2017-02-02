

"Represents benchmark function + test flow. I.e. functions called before / after test iteration."
tagged( "Bench" )
see( `function benchmark`, `class SingleBench`, `class MultiBench` )
since( "0.7.0" ) by( "Lis" )
shared interface BenchFlow<in Parameter>
		given Parameter satisfies Anything[]
{
	
	"Setups the benchmark test. Called before the test."
	shared formal void setup();
	
	"Called before each [[bench]] execution."
	shared formal void before();
	
	"Benchmark function."
	shared formal Anything(*Parameter) bench;
	
	"Called after each [[bench]] execution."
	shared formal void after();
	
	"Disposes the benchmark test. Called after the test."
	shared formal void dispose();
	
}


"Just [[bench]] function makes sense."
since( "0.7.0" ) by( "Lis" )
class EmptyBenchFlow<in Parameter> (
	shared actual Anything(*Parameter) bench
)
		satisfies BenchFlow<Parameter>
		given Parameter satisfies Anything[]
{
	shared actual void after() {}
	shared actual void before() {}
	shared actual void dispose() {}
	shared actual void setup() {}
}
