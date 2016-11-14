import herd.asynctest {
	TestVariantResult,
	TestOutput
}
import ceylon.test {
	TestState
}


"Identifies if test has to be repeated or completed."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared interface RepeatStrategy {
	
	"Starts repeating strategy from scratch.  
	 To be executed before each test repeating."
	shared formal void start();
	
	"Takes result of the latest run and identifies if test has to be repeat or completed:  
	 
	 * If returns `null` then the test is repeated.  
	 * If returns `TestVariantResult` then the test is completed and results are reported.
	 "
	shared formal TestVariantResult? completeOrRepeat (
		"Results of the test variant run." TestVariantResult variant
	);
}


"Repeats up to the first successfull run but no more than `maxRepeats` times.  
 Reports result from the latest run."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatUpToSuccessRun( Integer maxRepeats = 1 ) satisfies RepeatStrategy {
	
	variable Integer totalRuns = 1;
	
	shared actual void start() {
		totalRuns = 1;
	}
	
	shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant )
		=> if ( variant.overallState == TestState.success || totalRuns >= maxRepeats )
			then variant else null;
	
}


"Repeats up to the first failed run but no more than `maxRepeats` times.  
 Reports result from the latest run."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatUpToFailedRun( Integer maxRepeats = 1 ) satisfies RepeatStrategy {
	
	variable Integer totalRuns = 1;
	
	shared actual void start() {
		totalRuns = 1;
	}
	
	shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant )
			=> if ( variant.overallState > TestState.success || ++totalRuns > maxRepeats )
				then variant else null;
	
}


"Repeats up to the first failed message but no more than `maxRepeats` times.  
 Reports just this failed message."
tagged( "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatUpToFailureMessage( Integer maxRepeats = 1 ) satisfies RepeatStrategy {
	
	variable Integer totalRuns = 1;
	
	shared actual void start() {
		totalRuns = 1;
	}
	
	shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) {
		if ( variant.overallState > TestState.success || ++totalRuns > maxRepeats ) {
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
			return null;
		}
	}
	
}
