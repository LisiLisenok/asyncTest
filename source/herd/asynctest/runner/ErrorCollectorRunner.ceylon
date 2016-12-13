import herd.asynctest {
	TestInfo
}
import ceylon.test.engine {
	MultipleFailureException
}
import ceylon.test {
	TestState
}


"Collects all errors into a one `ceylon.test.engine::MultipleFailureException` exception.  
 Ignores success messages.  
 
 > Thread-safe.
 "
tagged( "Runner" )
since( "0.6.0" ) by( "Lis" )
shared class ErrorCollectorRunner() satisfies AsyncTestRunner {
		
	shared actual void run( AsyncRunnerContext context, void testing(AsyncRunnerContext context), TestInfo info ) {
		CollectorContext collect = CollectorContext();
		collect.start();
		testing( collect );
		value var = collect.variantResult;
		if ( var.overallState > TestState.success ) {
			value v = [for ( item in var.testOutput ) if ( exists r = item.error ) r ];
			if ( !v.empty ) {
				if ( v.size == 1, exists f = v.first ) {
					context.fail( f, "total 1 failure" );
				}
				else {
					context.fail( MultipleFailureException( v ), "total failures is ``v.size``" );
				}
			}
		}
		context.complete();
	}
	
}
