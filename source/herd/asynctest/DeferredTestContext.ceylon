import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration,
	OpenInterfaceType
}
import ceylon.test {
	TestState,
	TestResult
}
import ceylon.test.engine {
	DefaultTestExecutor,
	TestSkippedException
}
import ceylon.test.engine.spi {
	TestExecutionContext
}
import ceylon.test.event {
	TestSkippedEvent,
	TestErrorEvent
}


"Actualy test processing."
by( "Lis" )
class DeferredTestContext (
	"Test function." FunctionDeclaration functionDeclaration,
	"Class contained function or `null` if function is top level" ClassDeclaration? classDeclaration,
	"Parent execution context." TestExecutionContext parent,
	"Initializations." InitStorage inits
)
		extends DefaultTestExecutor( functionDeclaration, classDeclaration )
		satisfies RunnableTestContext
{	
	
	"dummy function used to after / before handles"
	void emptyExecute() {}
	
	
	"Executes one variant.
	 Returns output from this variant."
	VariantTestOutput executeVariant( InitStorage inits, TestExecutionContext context, Anything[] args ) {
		// object test to perform on
		Object? instance = getInstance( context );
		
		// run before callback and return aborted if failed
		try {
			handleBeforeCallbacks( context, instance, emptyExecute )();
		}
		catch ( Throwable err ) {
			return VariantTestOutput( [TestOutput( TestState.aborted, err, 0, "beforeTest" )], 0 );
		}
		
		// run test
		Tester tester = Tester( inits );
		value output = tester.run (
			( AsyncTestContext asyncContext ) {
				// invoke tested function
				if ( functionDeclaration.toplevel ) {
					functionDeclaration.invoke( [], asyncContext, *args );
				}
				else if ( exists i = instance ) {
					functionDeclaration.memberInvoke( i, [], asyncContext, *args );
				}
				else {
					assert ( exists decl = classDeclaration );
					throw AssertionError( "unable to instantiate object of test class ``decl``" );
				}
			}
		);
		
		// run after callbacks
		try {
			handleAfterCallbacks( context, instance, emptyExecute )();
		}
		catch ( Throwable err ) {
			return VariantTestOutput (
				output.append( [TestOutput( TestState.error, err, 0, "afterTest" )] ),
				tester.runInterval
			);
		}
		
		// test results
		return VariantTestOutput( output, tester.runInterval );
	}
	
	
	"Executes variant and fills results."
	void executeAndFillVariant( InitStorage inits, TestExecutionContext context, Anything[] args ) {
		value res = executeVariant( inits, context, args );
		asyncTestRunner.fillTestResults( context, res.outs, res.totalElapsedTime );
	}
	
	void executeVariants( InitStorage inits, TestExecutionContext context, {Anything[]*} argsVariants ) {
		variable Integer elapsedTime = 0;
		asyncTestRunner.testStartEvent( context );
		variable TestState state = TestState.skipped;
		variable Integer index = 1;
		for ( args in argsVariants ) {
			value executionResults = executeVariant( inits, context, args );
			elapsedTime += executionResults.totalElapsedTime;
			String varName = variantName( args );
			if ( executionResults.outs.empty ) {
				asyncTestRunner.testVariantResultEvent (
					context,
					TestOutput( TestState.success, null, executionResults.totalElapsedTime, "``varName`` - ``TestState.success``" ),
					index ++
				);
				if ( state < TestState.success ) { state = TestState.success; }
			}
			else {
				for ( variantOutput in executionResults.outs ) {
					String strTitle =	if ( variantOutput.title.empty )
										then " - ``variantOutput.state``"
										else " - ``variantOutput.state``: ``variantOutput.title``";
					asyncTestRunner.testVariantResultEvent (
						context,
						TestOutput (
							variantOutput.state, variantOutput.error, variantOutput.elapsedTime,
							"``varName````strTitle``"
						),
						index ++
					);
					if ( state < variantOutput.state ) { state = variantOutput.state; }
				}
			}
		}
		asyncTestRunner.testFinishEvent( context, TestResult( context.description, state, true, null, elapsedTime ) );
	}
	
	
	"Executes this test with initializations `inits` and parent execution context `parent`"
	void executeAsyncTest() {
		TestExecutionContext context = parent.childContext( description );
		try {
			// verify test
			verify( context );
			
			// test parameters - series of arguments
			value argLists = resolveArgumentList( functionDeclaration );
			Integer size = argLists.size;
			
			// execute test
			if ( size == 0 ) {
				executeAndFillVariant( inits, context, [] );
			}
			else if ( size == 1, exists args = argLists.first ) {
				executeAndFillVariant( inits, context, args );
			}
			else {
				executeVariants( inits, context, argLists );
			}
		}
		catch ( TestSkippedException e ) {
			context.fire().testSkipped( TestSkippedEvent( TestResult( description, TestState.skipped, false, e ) ) );
		}
		catch ( Throwable e ) {
			context.fire().testError( TestErrorEvent( TestResult( description, TestState.error, false, e ) ) );
		}
	}

	
	shared actual void runTest() {
		if ( isAsyncDeclaration( functionDeclaration ) ) {
			executeAsyncTest();
		}
		else {
			super.execute( parent );
		}
	}
	
	
	"Do nothing! use [[runTest]] instead"
	shared actual void execute( TestExecutionContext parent ) {
	}
	
	
	"returns `true` if function runs async test == takes `AsyncTestContext` as first argument"
	Boolean isAsyncDeclaration( FunctionDeclaration functionDeclaration ) {
		if ( nonempty argDeclarations = functionDeclaration.parameterDeclarations,
			is OpenInterfaceType argType = argDeclarations.first.openType,
			argType.declaration == `interface AsyncTestContext`
		) {
			return true;
		}
		else {
			return false;
		}
	}	
	

	String stringify( Anything item ) {
		switch ( item )
		case ( is Null ) { return "<null>"; }
		case ( is String ) { return "\"``item``\""; }
		case( is Character ) { return "'``item``'"; }
		else { return item.string; }
	}
	
	String variantName( Anything[] args ) {
		StringBuilder builder = StringBuilder();
		Integer size = args.size - 1;
		if ( size > 0 ) { builder.append( "parameters (" ); }
		else { builder.append( "parameter (" ); }
		for( arg in args.indexed ) {
			builder.append( stringify( arg.item ) );
			if( arg.key < size ) {
				builder.append(", ");
			}
		}
		builder.append( ")" );
		return builder.string;
	}
	
}
