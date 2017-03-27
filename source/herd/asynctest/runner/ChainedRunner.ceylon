


"Provides runners chaining:  
 the first runner executes the second one and so on,
 the last runner calls `testing` directly.  
 
 > Thread-safe.
 "
tagged( "Runner" )
since( "0.6.0" ) by( "Lis" )
shared class ChainedRunner (
	"Runners to be chained." AsyncTestRunner* runners
)
		satisfies AsyncTestRunner
{
	
	void runnerCaller( AsyncTestRunner runner, Anything(AsyncRunnerContext) testing, TestInfo info )( AsyncRunnerContext context ) {
		runner.run( context, testing, info );
	}
	
	shared actual void run( AsyncRunnerContext context, void testing(AsyncRunnerContext context), TestInfo info ) {
		variable Anything(AsyncRunnerContext) runTest = testing;
		for ( item in runners.reversed ) {
			runTest = runnerCaller( item, runTest, info );
		}
		runTest( context );
	}
	
}
