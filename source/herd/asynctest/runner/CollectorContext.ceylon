import herd.asynctest {
	VariantResultBuilder,
	TestVariantResult
}


"Context which collects results but not actually reports on.  
 To get results of the test run examine [[variantResult]]."
tagged( "Context" )
since( "0.6.0" ) by( "Lis" )
shared class CollectorContext() satisfies AsyncRunnerContext {
	
	VariantResultBuilder builder = VariantResultBuilder();
	
	
	"Summary results of the test run."
	shared TestVariantResult variantResult => builder.variantResult;
	
	"Starts collecting from scratch."
	shared default void start() => builder.start();
	
	shared actual default void complete( String title ) {}
	
	shared actual default void fail( Throwable|Anything() exceptionSource, String title ) {
		if ( is Throwable exceptionSource ) {
			builder.addFailure( exceptionSource, title );
		}
		else {
			try { exceptionSource(); }
			catch ( Throwable err ) { builder.addFailure( err, title ); }
		}
	}
	
	shared actual default void succeed( String message ) => builder.addSuccess( message );
	
}


"Context which collects results and delegates to another context.  
 To get results of the test run examine [[variantResult]]."
tagged( "Context" )
since( "0.6.0" ) by( "Lis" )
shared class CollectAndDelegateContext( "Delegate report to" AsyncRunnerContext delegateTo )
	extends CollectorContext()
{
	
	shared actual default void complete( String title ) {
		super.complete( title );
		delegateTo.complete( title );
	}
	
	shared actual default void fail( Throwable|Anything() exceptionSource, String title ) {
		if ( is Throwable exceptionSource ) {
			super.fail( exceptionSource, title );
			delegateTo.fail( exceptionSource, title );
		}
		else {
			try { exceptionSource(); }
			catch ( Throwable err ) {
				super.fail( err, title );
				delegateTo.fail( err, title );
			}
		}
	}
	
	shared actual default void succeed( String message ) {
		super.succeed( message );
		delegateTo.succeed( message );
	}
	
}

