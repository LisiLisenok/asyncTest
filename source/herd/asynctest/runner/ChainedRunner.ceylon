import herd.asynctest {
	AsyncMessageContext,
	TestInfo
}


"Provides runners chaining:  
 the first runner executes the second one and so on,
 the last runner calls `testing` directly.
 "
tagged( "Runner" )
since( "0.6.0" ) by( "Lis" )
shared class ChainedRunner (
	"Runners to be chained." AsyncTestRunner* runners
)
		satisfies AsyncTestRunner
{
	
	void runnerCaller( AsyncTestRunner runner, Anything(AsyncMessageContext) testing, TestInfo info )( AsyncMessageContext context ) {
		runner.run( context, testing, info );
	}
	
	shared actual void run( AsyncMessageContext context, void testing(AsyncMessageContext context), TestInfo info ) {
		variable Anything(AsyncMessageContext) runTest = testing;
		for ( item in runners.reversed ) {
			runTest = runnerCaller( item, runTest, info );
		}
		runTest( context );
	}
	
}
