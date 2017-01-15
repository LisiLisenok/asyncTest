import java.util.concurrent.atomic {
	AtomicLong
}


"Continues benchmark iterations while total number of iterations doesn't exceed [[numberOfIterations]].  
 Number of iterations is equal to number of calls of [[verify]] after last call of [[reset]].  
 So, the benchmark is completed when sum of iterations over all used threads reaches [[numberOfIterations]].  
 "
tagged( "Criteria" )
see( `class Options`, `class LocalIterations` )
throws( `class AssertionError`, "Total number of benchmark iterations is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class TotalIterations (
	"Total number of benchmark iterations. Has to be > 0." Integer numberOfIterations
)
		satisfies CompletionCriterion
{
	
	"Total number of benchmark iterations has to be > 0."
	assert( numberOfIterations > 0 );
	
	AtomicLong counter = AtomicLong( 1 );
	
	shared actual void reset() {
		counter.set( 1 );
	}
	
	shared actual Boolean verify( Float delta, StatisticAggregator stat, TimeUnit timeUnit ) {
		return counter.incrementAndGet() > numberOfIterations;
	}
	
}


"Continues benchmark iterations while local (relative to thread) number of iterations doesn't exceed [[numberOfIterations]].  
 Number of iterations is equal to number of calls of [[verify]] after last call of [[reset]]."
tagged( "Criteria" )
see( `class Options`, `class TotalIterations` )
throws( `class AssertionError`, "Thread local restriction on a number of benchmark iterations is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class LocalIterations (
	"Thread local restriction on a number of benchmark iterations. Has to be > 0." Integer numberOfIterations
)
		satisfies CompletionCriterion
{
	
	"Thread local restriction on a number of benchmark iterations has to be > 0."
	assert( numberOfIterations > 0 );
	
	
	shared actual void reset() {
	}
	
	shared actual Boolean verify( Float delta, StatisticAggregator stat, TimeUnit timeUnit ) {
		return stat.size >= numberOfIterations;
	}
	
}
