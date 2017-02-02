import java.lang {
	System
}


"Executes test function in a single thread."
tagged( "Bench" )
see( `function benchmark` )
since( "0.7.0" ) by( "Lis" )
shared final class SingleBench<Parameter=[]> (
	"Bench title. Generally unique."
	shared actual String title,
	"Function to be tested."
	Anything(*Parameter) | BenchFlow<Parameter> bench
)
	satisfies Bench<Parameter>
	given Parameter satisfies Anything[]
{
	
	BenchFlow<Parameter> actualBench = if ( is BenchFlow<Parameter> bench ) then bench else EmptyBenchFlow( bench );
	
	variable Integer? memoizedHash = null;
	
	shared actual Integer hash => memoizedHash else ( memoizedHash = 7 * title.hash + 37 );
	
	shared actual Boolean equals( Object other ) {
		if ( is SingleBench<Parameter> other ) {
			return title == other.title;
		}
		else {
			return false;
		}
	}
	
	"Executes test using the following cycle:  
	 * Cycle while [[Options.warmupCriterion]] is not met:
 		* Cycle of [[Options.iterationsPerLoop]]:  
 			* [[bench]]  
 			* Consume result returned by [[bench]] using [[pushToBlackHole]]  
	 * Cycle while [[Options.measureCriterion]] is not met:  
	 	* Cycle of [[Options.iterationsPerLoop]]:
	 		* [[bench]]  
	 		* Increment time spent on [[bench]] execution
	 		* Consume result returned by [[bench]] using [[pushToBlackHole]]
 		* Collect statistic in operations per time units  
	 "
	shared actual StatisticSummary execute (
		"Options the bench is executed with." Options options,
		"Execution parameter the benchmark function takes." Parameter parameter
	) {
		
		// clock to measure time interval
		Clock clock = options.clock();
		
		variable CompletionCriterion? warmupCriterion = options.warmupCriterion;
		StatisticAggregator calculator = StatisticAggregator();
		System.gc();
		
		actualBench.setup();
		// bench iterations
		while ( true ) {
			// test loop
			variable Float loopTime = 0.0;
			variable Integer loop = options.iterationsPerLoop;
			while ( loop -- > 0 ) {
				actualBench.before();
				// number of GC starts before test run
				Integer numGCBefore = numberOfGCRuns();
				// execute the test function
				clock.start();
				Anything ret = actualBench.bench( *parameter );
				Float delta = clock.measure( options.timeUnit );
				// number of GC starts after test run
				Integer numGCAfter = numberOfGCRuns();
				if ( numGCAfter == numGCBefore || !options.skipGCRuns ) {
					loopTime += delta;
				}
				else {
					loop ++;
				}
				// Eleminate JIT optimization
				pushToBlackHole( ret );
				actualBench.after();
			}
			
			// calculate execution statistic
			if ( loopTime > 0.0 ) {
				// add sample only if GC has not been started during the test or GC runs have not be skipped
				calculator.sample( options.iterationsPerLoop / loopTime );
				if ( exists criterion = warmupCriterion ) {
					if ( criterion.verify( calculator, options.timeUnit ) ) {
						// warmup round is completed
						warmupCriterion = null;
						calculator.reset();
						System.gc();
					}
				}
				else {
					if ( options.measureCriterion.verify( calculator, options.timeUnit ) ) {
						// measure round is completed
						break;
					}
				}
			}
		}
		
		actualBench.dispose();
		return calculator.result;
	}
	
}
