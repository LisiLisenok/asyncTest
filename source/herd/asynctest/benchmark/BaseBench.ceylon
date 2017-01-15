import java.lang.management {
	ManagementFactory
}


"Intended to implement details of bench execution in a signle thread.  
 
 Just [[bench]] has to be implemented which is indended to invoke test function once.    
 See [[execute]] for the run cycle.  
 "
tagged( "Bench" )
since( "0.7.0" ) by( "Lis" )
shared abstract class BaseBench<in Parameter> (
	shared actual String title
)
		satisfies Bench<Parameter>
		given Parameter satisfies Anything[]
{
	
	variable Integer? memoizedHash = null;
		
	shared actual default Integer hash => memoizedHash else ( memoizedHash = 7 * title.hash + 37 );
	
	
	"Executes optioned callbacks."
	void stageEvent (
		"Stage the event belongs to." Stage stage, "Callbacks." Anything(Stage)[] callbacks 
	) {
		for ( item in callbacks ) {
			item( stage );
		}
	}

	
	"Bench test function.  
	 May return results in order to avoid dead-code elimination.  
	 Returned result is consumed using [[pushToBlackHole]]."
	shared formal Anything(*Parameter) bench;
	

	"Returns number of GC runs up to now."
	Integer numberOfGCRuns() {
		value gcBeans = ManagementFactory.garbageCollectorMXBeans;
		variable Integer numGC = 0;
		for ( gcBean in gcBeans ) { numGC += gcBean.collectionCount; }
		return numGC;
	}
	
	"Executes test using the following cycle:  
	 * [[stageEvent]] with [[Stage.beforeWarmupRound]]  
	 * Cycle while [[Options.warmupCriterion]] is not met:  
	 	* [[stageEvent]] with [[Stage.beforeWarmupIteration]]  
	 	* [[bench]]  
	 	* consume result returned by [[bench]] using [[pushToBlackHole]]  
	 	* [[stageEvent]] with [[Stage.afterWarmupIteration]]  
	 * [[stageEvent]] with [[Stage.afterWarmupRound]]  
	 * [[stageEvent]] with [[Stage.beforeMeasureRound]]  
	 * Cycle while [[Options.measureCriterion]] is not met:  
	 	* [[stageEvent]] with [[Stage.beforeMeasureIteration]]  
	 	* [[bench]]  
	 	* collect time statistic  
	 	* consume result returned by [[bench]] using [[pushToBlackHole]]  
	 	* [[stageEvent]] with [[Stage.afterMeasureIteration]]  
	 * [[stageEvent]] with [[Stage.afterMeasureRound]]  
	 
	 > Note: runs when GC wroks are excluded from statistic calculations.  
	 "
	shared actual StatisticSummary execute (
		Options options, Parameter parameter
	) {
		
		// clock to measure time interval
		Clock clock = options.clock;
		// factor to scale time delta from nanoseconds (measured in) to timeUnit
		Float timeFactor = clock.units.factorToSeconds / options.timeUnit.factorToSeconds;
		
		variable CompletionCriterion? warmupCriterion = options.warmupCriterion;
		StatisticAggregator calculator = StatisticAggregator();
		if ( warmupCriterion exists ) { stageEvent( Stage.beforeWarmupRound, options.callbacks ); }
		else { stageEvent( Stage.beforeMeasureRound, options.callbacks ); }
		
		// bench iterations
		while ( true ) {
			// number of GC starts before test run
			Integer numGCBefore = numberOfGCRuns();
			// before iteration event
			if ( warmupCriterion exists ) { stageEvent( Stage.beforeWarmupIteration, options.callbacks ); }
			else { stageEvent( Stage.beforeMeasureIteration, options.callbacks ); }
			// execute the test function
			clock.start();
			Anything ret = bench( *parameter );
			Float delta = clock.measure() * timeFactor;
			// calculate execution statistic
			if ( delta > 0.0 ) {
				// number of GC starts after test run
				Integer numGCAfter = numberOfGCRuns();
				if ( numGCAfter == numGCBefore || !options.skipGCRuns ) {
					// add sample only if GC has not been started during the test or GC runs have not be skipped
					calculator.sample( 1.0 / delta );
					if ( exists criterion = warmupCriterion ) {
						if ( criterion.verify( delta, calculator, options.timeUnit ) ) {
							// warmup round is completed
							warmupCriterion = null;
							calculator.reset();
							stageEvent( Stage.afterWarmupIteration, options.callbacks );
							stageEvent( Stage.afterWarmupRound, options.callbacks );
							stageEvent( Stage.beforeMeasureRound, options.callbacks );
							continue;
						}
					}
					else {
						if ( options.measureCriterion.verify( delta, calculator, options.timeUnit ) ) {
							// measure round is completed
							stageEvent( Stage.afterMeasureIteration, options.callbacks );
							stageEvent( Stage.afterMeasureRound, options.callbacks );
							break;
						}
					}
				}
			}
			// completing iteration
			if ( warmupCriterion exists ) { stageEvent( Stage.afterWarmupIteration, options.callbacks ); }
			else { stageEvent( Stage.afterMeasureIteration, options.callbacks ); }
			pushToBlackHole( ret );
		}
		
		return calculator.result;
	}
	
}
