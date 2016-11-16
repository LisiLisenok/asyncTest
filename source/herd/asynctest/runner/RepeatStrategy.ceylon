import herd.asynctest {
	TestVariantResult,
	TestOutput
}
import ceylon.test {
	TestState
}


"Identifies if test has to be repeated or completed.  
 
 Pay attention: when implementing new strategy it has to take care to understand
 when it is started and when it is completed to be ready for the next repeating run.  
 "
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared interface RepeatStrategy {
	"Takes result of the latest run and identifies if test has to be repeat or completed:  
	 
	 * If returns `null` then the test is repeated.  
	 * If returns `TestVariantResult` then the test is completed and results are reported.
	 "
	shared formal TestVariantResult? completeOrRepeat (
		"Results of the test variant run." TestVariantResult variant
	);
}


"Repeats just once and returns the given test variant result."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared object repeatOnce satisfies RepeatStrategy {
	shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) => variant;
}


"Repeats up to the first successfull run but no more than `maxRepeats` times.  
 Reports result from the latest run."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatUpToSuccessRun( "Number of repeats limit." Integer maxRepeats = 1 ) satisfies RepeatStrategy {
	
	variable Integer? totalRuns = null;
	
	shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) {
		Integer count = ( totalRuns else 1 ) + 1;
		if ( variant.overallState == TestState.success || count > maxRepeats ) {
			totalRuns = null;
			return variant;
		}
		else {
			totalRuns = count;
			return null;
		}
	}
	
}


"Repeats up to the first failed run but no more than `maxRepeats` times.  
 Reports result from the latest run."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatUpToFailedRun( "Number of repeats limit." Integer maxRepeats = 1 ) satisfies RepeatStrategy {
	
	variable Integer? totalRuns = null;
	
	shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) {
		Integer count = ( totalRuns else 1 ) + 1;
		if ( variant.overallState > TestState.success || count > maxRepeats ) {
			totalRuns = null;
			return variant;
		}
		else {
			totalRuns = count;
			return null;
		}
	}
	
}


"Repeats up to the first failure message but no more than `maxRepeats` times.  
 Reports just this failed message."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatUpToFailureMessage( "Number of repeats limit." Integer maxRepeats = 1 ) satisfies RepeatStrategy {
	
	variable Integer? totalRuns = null;
	
	shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) {
		Integer count = ( totalRuns else 1 ) + 1;
		if ( variant.overallState > TestState.success || count > maxRepeats ) {
			totalRuns = null;
			for ( item in variant.testOutput ) {
				if ( exists reason = item.error ) {
					return TestVariantResult (
						[TestOutput( item.state, item.error, item.elapsedTime,
							if ( item.title.empty ) then "failure" else item.title
						)], variant.overallElapsedTime, item.state
					);
				}
			}
			else {
				return TestVariantResult (
					[TestOutput( TestState.success, null, variant.overallElapsedTime, "success" )],
					variant.overallElapsedTime, TestState.success
				);
			}
		}
		else {
			totalRuns = count;
			return null;
		}
	}
	
}
