import java.lang.management {
	ManagementFactory
}
import herd.asynctest.internal {
	SimpleStat
}


"Intended to implement details of bench execution in a signle thread.  
 
 Just [[runIteration]] has to be implemented which is indended to invoke test function once.    
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
	
	
	"Executed _before warmup round_ started. By default runs garbage collector."
	shared default void beforeWarmupRound( Options options ) {
		options.gcStrategy.gc( Stage.beforeWarmupRound );
	}
	
	"Executed _after warmup round_ has been completed. By default do nothing."
	shared default void afterWarmupRound( Options options ) {
		options.gcStrategy.gc( Stage.afterWarmupRound );
	}
	
	"Executed _before each_ warmup iteration. By default do nothing."
	shared default void beforeWarmupIteration( Options options ) {
		options.gcStrategy.gc( Stage.beforeWarmupIteration );
	}
	
	"Executed _after each_ warmup iteration. By default do nothing."
	shared default void afterWarmupIteration( Options options ) {
		options.gcStrategy.gc( Stage.afterWarmupIteration );
	}
	
	"Executed _before all_ measurements started. By default runs garbage collector."
	shared default void beforeMeasureRound( Options options ) {
		options.gcStrategy.gc( Stage.beforeMeasureRound );
	}
	
	"Executed _after all_ measurements have been completed. By default do nothing."
	shared default void afterMeasureRound( Options options ) {
		options.gcStrategy.gc( Stage.afterMeasureRound );
	}
	
	"Executed _before each_ iteration. By default do nothing."
	shared default void beforeMeasureIteration( Options options ) {
		options.gcStrategy.gc( Stage.beforeMeasureIteration );
	}
	
	"Executed _after each_ iteration. By default do nothing."
	shared default void afterMeasureIteration( Options options ) {
		options.gcStrategy.gc( Stage.afterMeasureIteration );
	}
	
	"Invokes a one test iteration.  
	 May return results in order to avoid dead-code elimination.  
	 Returned result is consumed using [[pushToBlackHole]]."
	shared formal Anything(*Parameter) runIteration;
	

	"Returns number of GC runs up to now."
	Integer numberOfGCRuns() {
		value gcBeans = ManagementFactory.garbageCollectorMXBeans;
		variable Integer numGC = 0;
		for ( gcBean in gcBeans ) { numGC += gcBean.collectionCount; }
		return numGC;
	}
	
	"Executes test using the following cycle:  
	 * [[beforeWarmupRound]]  
	 * Cycle while [[Options.warmupCriterion]] is not met:  
	 	* [[beforeWarmupIteration]]  
	 	* [[runIteration]]  
	 	* consume result returned by [[runIteration]] using [[pushToBlackHole]]  
	 	* [[afterWarmupIteration]]  
	 * [[afterWarmupRound]]  
	 * [[beforeMeasureRound]]  
	 * Cycle while [[Options.measureCriterion]] is not met:  
	 	* [[beforeMeasureIteration]]  
	 	* [[runIteration]]  
	 	* collect time statistic  
	 	* consume result returned by [[runIteration]] using [[pushToBlackHole]]  
	 	* [[afterMeasureIteration]]  
	 * [[afterMeasureRound]]  
	 
	 > Note: runs when GC wroks are excluded from statistic calculations.  
	 "
	shared actual StatisticSummary execute (
		Options options, Parameter parameter
	) {
		
		// intialize clock
		Clock clock = options.clock;
		clock.initialize();
		// factor to scale time delta from nanoseconds (measured in) to timeUnit
		Float timeFactor = TimeUnit.nanoseconds.factorToSeconds / options.timeUnit.factorToSeconds;
		
		// warmup round - clock is also warmupped!
		if ( exists warmupCriterion = options.warmupCriterion ) {
			SimpleStat calculator = SimpleStat();
			beforeWarmupRound( options );
			while ( true ) {
				beforeWarmupIteration( options );
				clock.start();
				Anything ret = runIteration( *parameter );
				Float delta = clock.measure() * timeFactor;
				if ( delta > 0.0 ) {
					calculator.sample( 1.0 / delta );
					if ( warmupCriterion.verify( delta, calculator.result, options.timeUnit ) ) {
						afterWarmupIteration( options );
						break;
					}
				}
				afterWarmupIteration( options );
				pushToBlackHole( ret );
			}
			afterWarmupRound( options );
		}
		
		// measure iterations
		SimpleStat calculator = SimpleStat();
		beforeMeasureRound( options );
		while ( true ) {
			// number of GC starts before test run
			Integer numGCBefore = numberOfGCRuns();
			// execute the test
			beforeMeasureIteration( options );
			clock.start();
			Anything ret = runIteration( *parameter );
			Float delta = clock.measure() * timeFactor;
			// calculate execution statistic
			if ( delta > 0.0 ) {
				// number of GC starts after test run
				Integer numGCAfter = numberOfGCRuns();
				if ( numGCAfter == numGCBefore ) {
					// add sample only if GC has not been started during the test
					calculator.sample( 1.0 / delta );
					if ( options.measureCriterion.verify( delta, calculator.result, options.timeUnit ) ) {
						// round is completed
						afterMeasureIteration( options );
						break;
					}
				}
			}
			// completing iteration
			afterMeasureIteration( options );
			pushToBlackHole( ret );
		}
		afterMeasureRound( options );
		return calculator.result;
	}
	
}
