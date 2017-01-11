import java.util.concurrent.atomic {
	AtomicLong
}
import java.lang {
	Thread
}
import java.util.concurrent {
	ConcurrentSkipListMap
}


"Continues benchmark iterations while overall time accumulated by benchmark iterations doesn't exceed
 [[totalTime]]."
tagged( "Criteria" )
see( `class Options`, `class LocalBenchTime` )
throws( `class AssertionError`, "Total benchmark time is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class TotalBenchTime (
	"Maximum time (in [[timeUnit]]) to be accumulated by benchmark iterations." Integer totalTime,
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
 [[localTime]]."
tagged( "Criteria" )
see( `class Options`, `class TotalBenchTime` )
throws( `class AssertionError`, "Local benchmark time is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class LocalBenchTime (
	"Maximum time (in [[timeUnit]]) to be accumulated by local (relative to thread) iterations." Integer localTime,
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
