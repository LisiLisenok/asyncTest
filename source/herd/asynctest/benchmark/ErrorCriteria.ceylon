import java.util.concurrent {
	ConcurrentSkipListMap
}
import java.lang {
	Thread,
	Math
}


"Continues benchmark iterations while total (over all threads) relative sample error doesn't exceed [[maxRelativeError]].  
 I.e. [[StatisticSummary.relativeSampleError]] is compared against [[maxRelativeError]]."
tagged( "Criteria" )
see( `class Options`, `class LocalError` )
throws( `class AssertionError`, "Maximum allowed total error is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class TotalError (
	"Maximum allowed total error. Has to be > 0." Float maxRelativeError,
	"Minimum number of iterations before check error.  Default is 10." Integer minIterations = 10
)
		satisfies CompletionCriterion
{
	
	"Maximum allowed total error has to be > 0."
	assert( maxRelativeError > 0.0 );
	
	ConcurrentSkipListMap<Integer, StatisticSummary> localStat = ConcurrentSkipListMap<Integer, StatisticSummary>( IntegerComparator() );
	
	
	shared actual void reset() {
		localStat.clear();
	}
	
	shared actual Boolean verify( Float delta, StatisticSummary result, TimeUnit timeUnit ) {
		Integer id = Thread.currentThread().id;
		localStat.put( id, result );
		variable Integer size = 0;
		variable Float mean = 0.0;
		variable Float variance = 0.0;
		for ( item in localStat.values() ) {
			size += item.size;
			mean += item.mean;
			variance += item.variance;
		}
		if ( size > minIterations ) {
			return Math.sqrt( variance / ( size - 1 ) ) / mean < maxRelativeError;
		}
		else {
			return false;
		}
	}
	
}


"Continues benchmark iterations while thread local relative sample error doesn't exceed [[maxRelativeError]].  
 I.e. [[StatisticSummary.relativeSampleError]] is compared against [[maxRelativeError]]."
tagged( "Criteria" )
see( `class Options`, `class TotalError` )
throws( `class AssertionError`, "Maximum allowed local error is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class LocalError (
	"Maximum allowed local error. Has to be > 0." Float maxRelativeError,
	"Minimum number of iterations before check error.  Default is 10." Integer minIterations = 10
)
		satisfies CompletionCriterion
{
	
	"Maximum allowed local error has to be > 0."
	assert( maxRelativeError > 0.0 );
	
	
	shared actual void reset() {
	}
	
	shared actual Boolean verify( Float delta, StatisticSummary result, TimeUnit timeUnit ) {
		return result.size > minIterations && result.relativeSampleError < maxRelativeError;
	}
	
}
