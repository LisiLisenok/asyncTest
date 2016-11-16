import herd.asynctest {
	AsyncMessageContext,
	TestInfo,
	retry,
	TestVariantResult
}


"Runner which repeats test execution a number of times identified by `strategy` but at least once.  
 
 The runner repeats a number of time according to repeat strategy given by inner [[Repeater]] class.  
 Such factory approach is preferable before delegation in multithread environment
 and helps to avoid errors related to race conditions. Since each runner invoking
 uses each own instance of the repeat strategy.  
 
 In order to implement custom strategy just implement [[RepeatRunner]] class
 and actualize inner [[Repeater]] class.  
 
 The runner repeats only test function execution! All `before`, `after` and `testRule` callbacks
 are executed _once_. In order to repeat overal test execution cycle see [[retry]].  
 
 > Free of race conditions in concurrent mode (see, [[herd.asynctest::concurrent]]).
 "
see( `function retry` )
tagged( "Runner", "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared abstract class RepeatRunner()
		satisfies AsyncTestRunner
{
	
	"Strategy which identifies test repeat times and reported results.  
	 Each time when runner is executed new instance is created.  
	 Such factory approach is preferable before delegation in multithread environment
	 and helps to avoid race conditions.  
	 Each implementation of `RepeatRunner` may have its own strategy."
	shared formal class Repeater() satisfies RepeatStrategy {}

	
	shared actual void run( AsyncMessageContext context, void testing(AsyncMessageContext context), TestInfo info ) {
		CollectorContext collect = CollectorContext();
		RepeatStrategy strategy = Repeater();
		while ( true ) {
			collect.start();
			testing( collect );
			if ( exists ret = strategy.completeOrRepeat( collect.variantResult ) ) {
				for ( result in ret.testOutput ) {
					if ( exists reason = result.error ) {
						context.fail( reason, result.title );
					}
					else if ( !result.title.empty ){
						context.succeed( result.title );
					}
				}
				context.complete();
				break;
			}
		}
	}
	
}


"Runner which repeats up to the first successfull run but no more then `maxRepeats`."
see( `class RepeatUpToSuccessRun` )
tagged( "Runner", "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class UpToSuccessRepeater( "Number of repeats limit." Integer maxRepeats = 1 )
	extends RepeatRunner() 
{
	shared actual class Repeater() extends super.Repeater() {
		RepeatStrategy strategy = RepeatUpToSuccessRun( maxRepeats );
		shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) => strategy.completeOrRepeat( variant );
	}
}


"Runner which repeats up to the first failed run but no more then `maxRepeats`."
see( `class RepeatUpToFailedRun` )
tagged( "Runner", "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class UpToFailureRepeater( "Number of repeats limit." Integer maxRepeats = 1 )
		extends RepeatRunner() 
{
	shared actual class Repeater() extends super.Repeater() {
		RepeatStrategy strategy = RepeatUpToFailedRun( maxRepeats );
		shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) => strategy.completeOrRepeat( variant );
	}
}


"Runner which repeats up to the first failure message but no more then `maxRepeats`."
see( `class RepeatUpToFailureMessage` )
tagged( "Runner", "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class UpToFailureMessageRepeater( "Number of repeats limit." Integer maxRepeats = 1 )
		extends RepeatRunner() 
{
	shared actual class Repeater() extends super.Repeater() {
		RepeatStrategy strategy = RepeatUpToFailureMessage( maxRepeats );
		shared actual TestVariantResult? completeOrRepeat( TestVariantResult variant ) => strategy.completeOrRepeat( variant );
	}
}
