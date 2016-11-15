import herd.asynctest {
	AsyncMessageContext,
	TestInfo,
	retry
}


"Runner which repeats test execution a number of times identified by `strategy` but at least once.  
 A number of repeat strategies are available:  
 * [[RepeatUpToSuccessRun]] - repeats up to the first successfull run.  
 * [[RepeatUpToFailedRun]] - repeats up to the first failed run.  
 * [[RepeatUpToFailureMessage]] - repeats up to the first failed message.  
 
 In order to implement custom strategy just implement [[RepeatStrategy]] interface.  
 Pay attention: strategy has to take care to understand when it is started and when it is completed
 to be ready for the next repeating run.  
 
 The runner repeats only test function execution! All `before`, `after` and `testRule` callbacks
 are executed _once_. In order to repeat overal test execution cycle see [[retry]].  
 
 > Free of race conditions in concurrent mode (see, [[herd.asynctest::concurrent]]).
 "
see( `function retry` )
tagged( "Runner", "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatRunner( "Strategy which identifies test repeat times and reported results." RepeatStrategy strategy )
		satisfies AsyncTestRunner
{
	
	shared actual void run( AsyncMessageContext context, void testing(AsyncMessageContext context), TestInfo info ) {
		CollectorContext collect = CollectorContext();
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
