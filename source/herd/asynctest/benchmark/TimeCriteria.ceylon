import java.util.concurrent.atomic {
	AtomicLong
}
import java.lang {
	Thread
}
import java.util.concurrent {
	ConcurrentSkipListMap
}


"Continues benchmark iterations while total execution time doesn't exceed [[timeLimit]].  
 Execution time is overall time spent on test execution.
 I.e. it summarizes time spent on benchmark function execution as well as on internal calculations.  
 
 The alternative way is take into account time spent on benchmark function execution only is realized
 in [[LocalBenchTime]] and [[TotalBenchTime]].  
 "
tagged( "Criteria" )
see( `class Options`, `class LocalBenchTime`, `class TotalBenchTime` )
throws( `class AssertionError`, "Maximum permited execution is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class TotalExecutionTime (
	"Maximum permited execution time in [[timeUnit]] units." Integer timeLimit,
	"Unit the [[timeLimit]] is measured in.  Default is milliseconds." TimeUnit timeUnit = TimeUnit.milliseconds	
)
		satisfies CompletionCriterion
{
	"Maximum permited execution has to be > 0."
	assert( timeLimit > 0 );
	Integer totalNanoseconds = ( timeLimit * timeUnit.factorToSeconds / TimeUnit.nanoseconds.factorToSeconds + 0.5 ).integer;
	
	variable Integer startTime = 0;
	
	
	shared actual void reset() {
		startTime = system.nanoseconds;
	}
	
	shared actual Boolean verify( Float delta, StatisticSummary result, TimeUnit deltaTimeUnit ) {
		return system.nanoseconds - startTime > totalNanoseconds;
	}
	
}


"Continues benchmark iterations while overall time accumulated by benchmark iterations doesn't exceed
 [[totalTime]].  
 This criterion summarizes only time spent on benchmark function execution for all execution threads jointly.  
 
 If benchmark function execution time is to be summarized for each thread separately [[LocalBenchTime]] is to be used.  
 If overall execution time has to be taken into account [[TotalExecutionTime]] is to be used.
 "
tagged( "Criteria" )
see( `class Options`, `class LocalBenchTime`, `class TotalExecutionTime` )
throws( `class AssertionError`, "Total benchmark time is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class TotalBenchTime (
	"Maximum time (in [[timeUnit]] units) to be accumulated by benchmark iterations." Integer totalTime,
	"Unit the [[totalTime]] is measured in.  Default is milliseconds." TimeUnit timeUnit = TimeUnit.milliseconds	
)
		satisfies CompletionCriterion
{
	"Total benchmark time has to be > 0."
	assert( totalTime > 0 );
	Integer totalNanoseconds = ( totalTime * timeUnit.factorToSeconds / TimeUnit.nanoseconds.factorToSeconds + 0.5 ).integer;
	
	AtomicLong accumulatedTime = AtomicLong( 0 );
	
	
	shared actual void reset() {
		accumulatedTime.set( 0 );
	}
	
	shared actual Boolean verify( Float delta, StatisticSummary result, TimeUnit deltaTimeUnit ) {
		Integer timeToAdd = ( delta * deltaTimeUnit.factorToSeconds / TimeUnit.nanoseconds.factorToSeconds + 0.5 ).integer;
		return accumulatedTime.addAndGet( timeToAdd ) > totalNanoseconds;
	}
	
}


"Continues benchmark iterations while local (relative to thread) time accumulated by benchmark iterations doesn't exceed
 [[localTime]].  
 This criterion summarizes time spent on benchmark function execution for each thread separately.  
 
 If benchmark function execution time is to be summarized for all threads [[TotalBenchTime]] is to be used.  
 If overall execution time has to be taken into account [[TotalExecutionTime]] is to be used.  
 "
tagged( "Criteria" )
see( `class Options`, `class TotalBenchTime`, `class TotalExecutionTime` )
throws( `class AssertionError`, "Local benchmark time is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class LocalBenchTime (
	"Maximum time (in [[timeUnit]] units) to be accumulated by local (relative to thread) iterations." Integer localTime,
	"Unit the [[localTime]] is measured in.  Default is milliseconds." TimeUnit timeUnit = TimeUnit.milliseconds
)
		satisfies CompletionCriterion
{
	
	"Thread local benchmark time has to be > 0."
	assert( localTime > 0 );
	Integer nanoseconds = ( localTime * timeUnit.factorToSeconds / TimeUnit.nanoseconds.factorToSeconds + 0.5 ).integer;
	
	ConcurrentSkipListMap<Integer, Integer> localAccumulators = ConcurrentSkipListMap<Integer, Integer>( IntegerComparator() );
	
	
	shared actual void reset() {
		localAccumulators.clear();
	}
	
	shared actual Boolean verify( Float delta, StatisticSummary result, TimeUnit deltaTimeUnit ) {
		Integer id = Thread.currentThread().id;
		Integer timeVal;
		if ( exists current = localAccumulators.get( id ) ) {
			timeVal = current + ( delta * deltaTimeUnit.factorToSeconds / TimeUnit.nanoseconds.factorToSeconds + 0.5 ).integer;
		}
		else {
			timeVal = ( delta * deltaTimeUnit.factorToSeconds / TimeUnit.nanoseconds.factorToSeconds + 0.5 ).integer;
		}
		localAccumulators.put( id, timeVal );
		return timeVal > nanoseconds;
	}
	
}
