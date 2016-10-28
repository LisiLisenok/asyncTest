import herd.asynctest {
	AsyncPrePostContext,
	AsyncTestContext
}


"Test rule which reports failure if test takes more time than specified in [[timeOut]] milliseconds.  
 
 > The rule doesn't actually interrupt test execution!  
 "
since( "0.6.0" ) by( "Lis" )
shared class TimeOutReport (
	"Maximum time in milliseconds the test to be executed." Integer timeOut,
	"`true` if success to be reported and `false` otherwise." Boolean resportSuccess = false
)
		satisfies TestRule & TestStatement
{
	variable Integer testStarted = system.milliseconds;
	
	shared actual void after( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void apply( AsyncTestContext context ) {
		Integer elapsed = system.milliseconds - testStarted;
		if ( elapsed > timeOut ) {
			context.fail( AssertionError( "The test takes ``elapsed``ms while expected timeout is ``timeOut``ms" ), "time out" );
		}
		else if ( resportSuccess ) {
			context.succeed( "Execution time ``elapsed``ms <= expected of ``timeOut``ms" );
		}
		context.complete();
	}
	
	shared actual void before( AsyncPrePostContext context ) {
		testStarted = system.milliseconds;
		context.proceed();
	}
	
}
