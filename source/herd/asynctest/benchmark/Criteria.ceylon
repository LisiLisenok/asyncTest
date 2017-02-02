

"Continues benchmark iterations while total number of benchmark loops doesn't exceed [[numberOfLoops]].  
 "
tagged( "Criteria" )
see( `class Options` )
throws( `class AssertionError`, "Total number of benchmark loops is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class NumberOfLoops (
	"Total number of benchmark loops. Has to be > 0." Integer numberOfLoops
)
		satisfies CompletionCriterion
{
	
	"Total number of benchmark loops has to be > 0."
	assert( numberOfLoops > 0 );

	
	shared actual void reset() {
	}
	
	shared actual Boolean verify( Statistic stat, TimeUnit timeUnit ) {
		return stat.size >= numberOfLoops;
	}
	
}


"Continues benchmark iterations while relative sample error doesn't exceed [[maxRelativeError]].  
 I.e. [[StatisticSummary.relativeSampleError]] is compared against [[maxRelativeError]]."
tagged( "Criteria" )
see( `class Options` )
throws( `class AssertionError`, "Maximum allowed error is <= 0." )
since( "0.7.0" ) by( "Lis" )
shared class ErrorCriterion (
	"Maximum allowed error. Has to be > 0." Float maxRelativeError,
	"Minimum number of iterations before check error.  Default is 10." Integer minIterations = 10
)
		satisfies CompletionCriterion
{
	
	"Maximum allowed error has to be > 0."
	assert( maxRelativeError > 0.0 );
	
	
	shared actual void reset() {
	}
	
	shared actual Boolean verify( Statistic stat, TimeUnit timeUnit ) {
		return stat.size > minIterations && stat.relativeSampleError < maxRelativeError;
	}
	
}


"Continues benchmark iterations while total execution time doesn't exceed [[timeLimit]].  
 Execution time is overall time spent on test execution.
 I.e. it summarizes time spent on benchmark function execution as well as on internal calculations.  
 
 The alternative way is take into account time spent on benchmark function execution only see [[TotalBenchTime]].  
 "
tagged( "Criteria" )
see( `class Options`, `class TotalBenchTime` )
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
	
	shared actual Boolean verify( Statistic stat, TimeUnit deltaTimeUnit ) {
		return system.nanoseconds - startTime > totalNanoseconds;
	}
	
}


"Continues benchmark iterations while overall time accumulated by benchmark iterations doesn't exceed
 [[totalTime]].  
 This criterion summarizes only time spent on benchmark function execution for all execution threads jointly.  
 "
tagged( "Criteria" )
see( `class Options`, `class TotalExecutionTime` )
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
	
	
	shared actual void reset() {
	}
	
	shared actual Boolean verify( Statistic stat, TimeUnit deltaTimeUnit ) {
		return ( stat.size / stat.mean * deltaTimeUnit.factorToSeconds / TimeUnit.nanoseconds.factorToSeconds + 0.5 ).integer
				> totalNanoseconds;
	}
	
}
