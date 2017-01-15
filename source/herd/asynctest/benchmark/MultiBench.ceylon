import java.util.concurrent.locks {
	ReentrantLock
}
import java.util.concurrent {
	CyclicBarrier,
	CountDownLatch
}
import java.lang {
	Thread,
	Math
}


"Executes bench functions `benches` in separated threads.  
 Number of threads for each bench function is specified by the bench parameter with corresponding index.  
 I.e. given list of bench function `benches` and list of `Integer` (`parameter` argument of [[execute]]).  
 For each bench function with index `index` number of threads to execute the function is specified via
 item of `parameter` list with the same index `index`.   
 So the bench is parameterized by number of execution threads.   
 "
tagged( "Bench" )
since( "0.7.0" ) by( "Lis" )
shared class MultiBench (
	shared actual String title,
	"Bench functions." Anything()+ benches
)
		satisfies Bench<[Integer+]>
{
	
	ReentrantLock locker = ReentrantLock();
	variable Float min = infinity;
	variable Float max = -infinity;
	variable Float mean = 0.0;
	variable Float variance = 0.0;		
	variable Integer size = 0;
	
	
	void writeResults( CountDownLatch completeLatch )( StatisticSummary stat ) {
		locker.lock();
		try {
			if ( stat.min < min ) {
				min = stat.min;
			}
			if ( stat.max > max ) {
				max = stat.max;
			}
			mean += stat.mean;
			variance += stat.variance;
			size += stat.size;
			completeLatch.countDown();
		}
		finally {
			locker.unlock();
		}
	}
	
	void awaitBarrier( CyclicBarrier startBarrier )( Stage stage ) {
		if ( stage == Stage.beforeMeasureRound ) {
			startBarrier.await();
		}
	}
	
	throws( `class AssertionError`, "size of [[benches]] has to be equal to size of [[parameter]]")
	shared actual StatisticSummary execute (
		"Options the bench has to be executed with." Options options,
		"Number of threads the [[benches]] has to be executed with." [Integer+] parameter
	) {
		"Number of executed functions has to be equal to size of the number of threads list."
		assert( benches.size == parameter.size );
		
		// initialize summary statistic
		min = infinity;
		max = -infinity;
		mean = 0.0;
		variance = 0.0;		
		size = 0;
		
		Integer totalThreads = sum( parameter );
		// threads completion count down latch
		CountDownLatch completeLatch = CountDownLatch( totalThreads );
		// aggregates results
		Anything(StatisticSummary) completion = writeResults( completeLatch );
		// append to callback barrier awaiter before measure round - synchronizes measure round start
		Options passedOptions = appendCallbacksToOptions( options, awaitBarrier( CyclicBarrier( totalThreads ) ) );
		
		// run benches is separated threads
		for ( i in 0 : benches.size ) {
			assert ( exists threads = parameter[i] );
			assert ( exists bench = benches[i] );
			for ( j in 0 : threads ) {
				Thread (
					SyncBench (
						title + i.string + ":" + j.string, bench, completion, passedOptions, []
					)
				).start();
			}
		}
		// await bench completion
		completeLatch.await();
		
		// return results
		return StatisticSummary( min, max, mean, Math.sqrt( variance ), size );
	}
	
}
