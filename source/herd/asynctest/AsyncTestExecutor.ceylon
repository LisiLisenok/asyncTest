import ceylon.test {

	TestDescription,
	TestListener,
	TestResult,
	TestState,
	testExtension,
	parameters,
	afterTest,
	beforeTest,
	test,
	testExecutor,
	ignore
}
import ceylon.test.engine.spi {

	TestExecutor,
	TestExecutionContext,
	ArgumentProviderContext
}
import ceylon.language.meta.declaration {

	FunctionDeclaration,
	ClassDeclaration,
	OpenInterfaceType
}
import ceylon.test.event {

	TestStartedEvent,
	TestFinishedEvent,
	TestSkippedEvent,
	TestErrorEvent
}
import ceylon.test.engine {

	DefaultTestExecutor,
	TestSkippedException
}
import ceylon.test.annotation {

	ParametersAnnotation
}
import ceylon.collection {

	ArrayList
}


"Test executor.  
 
 #### capabilities
 * testing both classes and top level functions
 * parameterized testing with a set of function arguments, see [[parameters]] annotation
 * testing asynchronous multithread code
   (only one test function is run at the moment, main test thread waits when execution completes)
 * functions marked with [[afterTest]] and [[beforeTest]] annotations are executed <i>synchronously</i>.
   So put asynchrnous initialization logic into test function directly or perform initialization in
   separated thread and block tested thread while initialization completed
 * reporting several failures for a one particular test function
   (each failure is reported as test variant)
 * mark each failure with `String` title
 
 In order to utilize this executor capabilities test function has to accept [[AsyncTestContext]] as the first argument:
 		test void doTesting(AsyncTestContext context) {...}
 The other arguments have to be in accordance with `ceylon.test::parameters` annotation. 
 
 #### running
 To run the test using this executor [[testExecutor]] annotation to be applied:
 * at module level to apply to every functions / classes marked with test in the given module
 		testExecutor(\`class AsyncTestExecutor\`)
 		native(\"jvm\")
 		module mymodule \"1.0.0\"
 * at function level to apply to the given function only
 		testExecutor(\`class AsyncTestExecutor\`)
 		test void doTesting(AsyncTestContext context) {...}
 
 Following procedure is as usual for SDK `ceylon.test` module - mark tested functions with [[test]] annotation
 and run test in IDE or command line.
 
 
 #### test logic 
 There are four cases of tested function type:
 1. `Anything(AsyncTestContext)` - executed using this test executor.  
 2. `parameters(`...`) Anything(AsyncTestContext, ...)` -
 executed using this test executor with several variants provided by [[parameters]] annotation.  
 3. `Anything()` - executed using `ceylon.test` SDK [[DefaultTestExecutor]].  
 4. `parameters(`...`) Anything(...)` - executed using `ceylon.test` SDK [[DefaultTestExecutor]]
 with several variants provided by [[parameters]] annotation.  
 
 
 When test function taking [[AsyncTestContext]] as first argument is executed it is expected the function will do following steps:
 1. Initialization.
 2. Notifying test framework on test procedure starting - [[AsyncTestContext.start]].
 3. Performing the test, reporting on fails via [[AsyncTestContext]].
    Several error reports are allowed. Each fail report is represented as test variant.
 4. Disposing or cleaning.
 5. Notifying test framework on test procedure completion - [[AsyncTestContext.complete]].
    This step is nesseccary to continue testing with next execution.

 Test function is responsible to catch all exceptions / assertions and to redirect them to `AsyncTestContext`.
 
 
 #### ceylon.test features
 * After / before test hooks can be used by applying [[afterTest]] and [[beforeTest]] annotations.
   Functions marked by these annotations are executed <i>synchronously</i> after and before test correspondently.
 * Parametrized test with a set of variants can be performed using [[parameters]] annotation.
 * Test can be skipped marking it by [[ignore]] annotation.
 * Hooks the test with [[TestListener]] can be used. But all events except `TestRunStartedEvent` are raised after
   actual testing is completed. 
 * It is <i>not</i> recommended to use `ceylon.test::assertXXX` functions together with [[AsyncTestContext]],
   since this functions simply throws an exception which leads to testing completion.
   Use [[AsyncTestContext]] instead.
 
 "
by( "Lis" )
see( `function testExtension` )
see( `interface AsyncTestContext` )
shared class AsyncTestExecutor (
	FunctionDeclaration functionDeclaration,
	ClassDeclaration? classDeclaration
)
		extends DefaultTestExecutor( functionDeclaration, classDeclaration )
		satisfies TestExecutor
{
	
	void fillResults( TestExecutionContext context, TestOutput[] results, Integer runInterval ) {
		TestDescription runDescription = context.description;
		context.fire().testStarted( TestStartedEvent( runDescription ) );
		if ( nonempty results ) {
			variable Integer index = 0;
			for ( res in results ) {
				String str = if ( res.title.empty ) then res.state.string else res.state.string + ": " + res.title;
				String title = if ( res.preamble.empty ) then str else res.preamble + " - " + str;
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
			context.fire().testFinished( TestFinishedEvent(
				TestResult( runDescription, state, true, null, runInterval )
			) );
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
	VariantTestOutput executeVariant( TestExecutionContext context, Anything[] args ) {
		Object? instance = getInstance( context );
		Tester tester = Tester (
			handleBeforeCallbacks( context, instance, emptyExecute ),
			handleAfterCallbacks( context, instance, emptyExecute ) 
		);
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
		return VariantTestOutput( output, tester.runInterval );
	}
	
	
	"Executes variant and fills results"
	void executeAndFillVariant( TestExecutionContext context, Anything[] args ) {
		value res = executeVariant( context, args );
		fillResults( context, res.outs, res.totalElapsedTime );
	}
	
	"Executes a number of variants."
	void executeVariants( TestExecutionContext context, {Anything[]*} argsVariants ) {
		variable Integer elapsedTime = 0;
		ArrayList<TestOutput> outs = ArrayList<TestOutput>(); 
		for ( args in argsVariants ) {
			value res = executeVariant( context, args );
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
	
	"Extracts test parameters from `parameters` annotation of tested function."
	{Anything[]*} resolveParameters() {
		if ( nonempty params = functionDeclaration.annotations<ParametersAnnotation>() ) {
			return params.first.argumentLists( ArgumentProviderContext( description, functionDeclaration, null ) );
		}
		return [];
	}
	
	
	shared actual void execute( TestExecutionContext parent ) {
		if ( nonempty argDeclarations = functionDeclaration.parameterDeclarations,
			 is OpenInterfaceType argType = argDeclarations.first.openType,
			 argType.declaration == `interface AsyncTestContext`
		) {
			TestExecutionContext context = parent.childContext( description );
			try {
				// verify test
				verify( context );
				// check if test conditions are met
				evaluateTestConditions( context );
				
				// test parameters - series of arguments
				value argLists = resolveParameters();
				Integer size = argLists.size;
				
				// execute test
				if ( size == 0 ) {
					executeAndFillVariant( context, [] );
				}
				else if ( size == 1, exists args = argLists.first ) {
					executeAndFillVariant( context, args );
				}
				else {
					executeVariants( context, argLists );
				}
				
			}
			catch ( TestSkippedException e ) {
				context.fire().testSkipped( TestSkippedEvent( TestResult( description, TestState.skipped, false, e ) ) );
			}
			catch ( Throwable e ) {
				context.fire().testError( TestErrorEvent( TestResult( description, TestState.error, false, e ) ) );
			}
		}
		else {
			super.execute( parent );
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
