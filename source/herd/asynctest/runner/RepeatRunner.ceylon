import herd.asynctest {
	AsyncMessageContext,
	TestInfo
}


"Runner which repeats test execution a number of times identified by `strategy` but at least once.  
 A number of repeat strategies are available:  
 * [[RepeatUpToSuccessRun]] - repeats up to the first successfull run.  
 * [[RepeatUpToFailedRun]] - repeats up to the first failed run.  
 * [[RepeatUpToFailureMessage]] - repeats up to the first failed message.  
 "
tagged( "Runner", "Repeat" )
since( "0.6.0" ) by( "Lis" )
shared class RepeatRunner( "Strategy which identifies test repeat times and reported results." RepeatStrategy strategy )
		satisfies AsyncTestRunner
{
	
	CollectorContext collect = CollectorContext();
	
	shared actual void run( AsyncMessageContext context, void testing(AsyncMessageContext context), TestInfo info ) {
		strategy.start();
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
