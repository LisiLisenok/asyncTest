import ceylon.collection {
	HashMap
}


"Runs benchmark testing.  
 Executes each given bench with each given parameter.  
 Bench is responsible for the execution details and calculation performance statistic."
throws( `class AssertionError`, "number of measure rounds is <= 0" )
since( "0.7.0" ) by( "Lis" )
shared Result<Parameter> benchmark<Parameter> (
	"Benchmark options of benches executing."
	Options options,
	"A list of benches to be executed."
	Bench<Parameter>[] benches,
	"A list of parameters the test has to be executed with."
	Parameter* parameters
)
		given Parameter satisfies Anything[]
{	
	if ( parameters nonempty ) {
		// run test for each parameter and each bench
		HashMap<Parameter, ParameterResult<Parameter>> res = HashMap<Parameter, ParameterResult<Parameter>>();
		for ( param in parameters ) {
			if ( !res.defines( param ) ) {
				HashMap<Bench<Parameter>, StatisticSummary> benchRes = HashMap<Bench<Parameter>, StatisticSummary>();
				for ( bench in benches ) {
					if ( !benchRes.defines( bench ) ) {
						// initialize black hole
						blackHole.clear();
						// initialize criteria
						options.measureCriterion.reset();
						options.warmupCriterion?.reset();
						// execute bench
						value br = bench.execute( options, param );
						// store results
						benchRes.put( bench, br );
						// avoid dead code elimination for the black hole
						blackHole.verifyNumbers();
					}
				}
				res.put( param, ParameterResult<Parameter>( param, benchRes ) );
			}
		}
		return Result<Parameter>( options.timeUnit, res );
	}
	else {
		// parameter list is empty! only empty parameters test is admited
		"benchmarking: if parameter list is empty, `Parameter` has to be `empty`."
		assert ( [] is Parameter );
		assert ( is Bench<[]>[] benches );
		
		HashMap<[], ParameterResult<[]>> res = HashMap<[], ParameterResult<[]>>();
		HashMap<Bench<[]>, StatisticSummary> benchRes = HashMap<Bench<[]>, StatisticSummary>();
		for ( bench in benches ) {
			if ( !benchRes.defines( bench ) ) {
				// initialize black hole
				blackHole.clear();
				// initialize criteria
				options.measureCriterion.reset();
				options.warmupCriterion?.reset();
				// execute bench
				value br = bench.execute( options, [] );
				// store results
				benchRes.put( bench, br );
				// avoid dead code elimination for the black hole
				blackHole.verifyNumbers();
			}
		}
		res.put( [], ParameterResult<[]>( [], benchRes ) );
		assert ( is Result<Parameter> ret = Result<[]>( options.timeUnit, res ) );
		return ret;
	}
}
