import ceylon.collection {
	ArrayList
}
import ceylon.language.meta.declaration {
	FunctionDeclaration,
	ClassDeclaration,
	OpenInterfaceType
}
import ceylon.test {
	TestState,
	TestResult,
	TestListener,
	TestDescription
}
import ceylon.test.engine {
	DefaultTestExecutor,
	TestSkippedException
}
import ceylon.test.engine.spi {
	TestExecutionContext
}
import ceylon.test.event {
	TestStartedEvent,
	TestSkippedEvent,
	TestFinishedEvent,
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
	
	"Fills results of the test to execution context."
	void fillResults (
		"Context to be filled with results." TestExecutionContext context,
		"Test results." TestOutput[] results,
		"Total test elapsed time." Integer runInterval
	) {
		TestDescription runDescription = context.description;
		context.fire().testStarted( TestStartedEvent( runDescription ) );
		if ( nonempty results ) {
			variable Integer index = 0;
			for ( res in results ) {
				String str = if ( res.title.empty ) then res.state.string else res.state.string + ": " + res.title;
				String title = if ( res.prefix.empty ) then str else res.prefix + " - " + str;
				TestDescription variant = runDescription.forVariant( title, ++ index );
				TestExecutionContext child = context.childContext( variant );
				TestListener listener = child.fire();
				listener.testStarted( TestStartedEvent( variant ) );
				listener.testFinished( TestFinishedEvent(
					TestResult( variant, res.state, false, res.error, res.elapsedTime )
				) );
			}
			variable TestState state = results.first.state;
			for ( item in results.rest ) {
				if ( item.state > state ) { state = item.state; }
			}
			context.fire().testFinished (
				TestFinishedEvent( TestResult( runDescription, state, true, null, runInterval ) )
			);
		}
		else {
			context.fire().testFinished (
				TestFinishedEvent( TestResult( runDescription, TestState.success, false, null, runInterval ) )
			);
		}
	}
	
	
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
		fillResults( context, res.outs, res.totalElapsedTime );
	}
	
	"Executes a number of variants."
	void executeVariants( InitStorage inits, TestExecutionContext context, {Anything[]*} argsVariants ) {
		variable Integer elapsedTime = 0;
		ArrayList<TestOutput> outs = ArrayList<TestOutput>(); 
		for ( args in argsVariants ) {
			value res = executeVariant( inits, context, args );
			elapsedTime += res.totalElapsedTime;
			String preamble = variantName( args );
			if ( res.outs.empty ) {
				outs.add( TestOutput ( TestState.success, null, res.totalElapsedTime, "", preamble ) );
			}
			else {
				outs.addAll (
					res.outs.map (
						( TestOutput testOutput ) => TestOutput (
							testOutput.state, testOutput.error, testOutput.elapsedTime, testOutput.title, preamble
						)
					)
				);
			}
		}
		fillResults( context, outs.sequence(), elapsedTime );
	}
	
	"Executes this test with initializations `inits` and parent execution context `parent`"
	void executeWithInits( InitStorage inits, TestExecutionContext parent ) {
		TestExecutionContext context = parent.childContext( description );
		try {
			// verify test
			verify( context );
			// check if test conditions are met
			evaluateTestConditions( context );
			
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
			executeWithInits( inits, parent );
		}
		else {
			super.execute( parent );
		}
	}
	
	
	"Do nothing!"
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
		if ( args.size > 1 ) { builder.append( "parameters (" ); }
		else { builder.append( "parameter (" ); }
		for( arg in args.indexed ) {
			builder.append( stringify( arg.item ) );
			if( arg.key < args.size - 1 ) {
				builder.append(", ");
			}
		}
		builder.append( ")" );
		return builder.string;
	}
	
}
