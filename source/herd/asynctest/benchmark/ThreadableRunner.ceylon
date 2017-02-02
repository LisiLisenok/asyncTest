import java.lang {
	Runnable,
	Thread,
	System
}
import java.util.concurrent {
	CyclicBarrier
}
import java.util.concurrent.atomic {
	AtomicInteger
}


"Base class for family of benches runners in several threads."
since( "0.7.0" ) by( "Lis" )
abstract class ThreadableRunner( "Options the bench is executed with." Options options ) {
	
	"Barrier which synchronizes loop starting."
	variable CyclicBarrier loopBarrier = CyclicBarrier( 1 );
	"Barrier which synchronizes statistic calculation."
	variable CyclicBarrier calculateBarrier = CyclicBarrier( 1 );
	"`true` if benchmarkis completed and `false` otherwise."
	variable Boolean running = true;
	"Total number of threads currently invoking bench function."
	AtomicInteger benchThreads = AtomicInteger( 0 );
	
	
	shared class RunnableBench( "Benchmark function." BenchFlow<[]> bench ) satisfies Runnable {
		
		"Time spent in the latest loop."
		shared variable Float loopTime = 0.0;
		
		"Level of concurency is mean number of threads invoked bench functions concurrently in the latest loop."
		shared variable Float concurrencyLevel = 0.0;
		
		shared actual void run() {
			Clock clock = options.clock();
			bench.setup();
			while ( running ) {
				// test loop
				variable Integer concurrentSamples = 0;
				concurrencyLevel = 0.0;
				loopTime = 0.0;
				variable Integer loop = options.iterationsPerLoop;
				while ( loop -- > 0 ) {
					bench.before();
					// number of GC starts before test run
					Integer numGCBefore = numberOfGCRuns();
					// execute the test function
					clock.start();
					Integer threadsBefore = benchThreads.incrementAndGet();
					Anything ret = bench.bench();
					Integer threadsAfter = benchThreads.andDecrement;
					Float delta = clock.measure( options.timeUnit );
					// number of GC starts after test run
					Integer numGCAfter = numberOfGCRuns();
					if ( numGCAfter == numGCBefore || !options.skipGCRuns ) {
						// time spent on bench function execution
						loopTime += delta;
						// mean number of concurrently bench function threads
						concurrentSamples ++;
						Float concurrentDelta = 0.5 * ( threadsBefore + threadsAfter ) - concurrencyLevel;
						concurrencyLevel = concurrencyLevel + concurrentDelta / concurrentSamples;
					}
					else {
						loop ++;
					}
					// Eleminate JIT optimization
					pushToBlackHole( ret );
					bench.after();
				}
				// await while all loops to be completed
				loopBarrier.await();
				// await statistic data calculations to be completed
				calculateBarrier.await();
			}
			bench.dispose();
		}
	}
	
	
	"Instantiates benches."
	shared formal RunnableBench[] benches;
	
	
	"Executes the benchmark."
	shared StatisticSummary execute() {
		running = true;
		benchThreads.set( 0 );
		StatisticAggregator calculator = StatisticAggregator();
		loopBarrier = CyclicBarrier( benches.size + 1 );
		calculateBarrier = CyclicBarrier( benches.size + 1 );
		variable CompletionCriterion? warmupCriterion = options.warmupCriterion;
		Integer totalBenches = benches.size;
		
		// start benches
		for ( item in benches ) {
			Thread( item ).start();
		}
		// accumulate stat
		while ( true ) {
			loopBarrier.await();
			// calculate operations per time units
			variable Float meanOperations = 0.0;
			variable Float meanConcurrencyLevel = 0.0;
			for ( item in benches ) {
				meanOperations += options.iterationsPerLoop / item.loopTime;
				meanConcurrencyLevel += item.concurrencyLevel;
			}
			meanConcurrencyLevel /= totalBenches;
			meanOperations /= totalBenches; 
			calculator.sample( meanConcurrencyLevel * meanOperations );
			
			// completion verifying
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
					running = false;
					calculateBarrier.await();
					return calculator.result;
				}
			}
			benchThreads.set( 0 );
			calculateBarrier.await();
		}
	}
}
