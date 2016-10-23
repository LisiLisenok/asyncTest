import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import ceylon.test {

	TestState,
	TestResult,
	TestDescription
}
import ceylon.test.engine {

	TestSkippedException
}
import herd.asynctest.match {

	stringify
}
import ceylon.language.meta.model {

	Type,
	Function
}
import ceylon.language.meta {

	type
}


"Processes test execution."
since( "0.2.0" )
by( "Lis" )
class AsyncTestProcessor(
	"Emitting test results to." TestEventEmitter resultEmitter,
	"Test function." FunctionDeclaration functionDeclaration,
	"Object contained function or `null` if function is top level" Object? instance,
	"Parent execution context." TestExecutionContext parent,
	"Description the test performed on." TestDescription description,
	"Functions called before each test." Anything(AsyncInitContext)[] intializers,
	"Functions called after each test." Anything(AsyncTestContext)[] cleaners
) {

	Type<Object>? instanceType = if ( exists i = instance ) then type( i ) else null;

	"`true` if test function is run on async test context."
	Boolean runOnAsyncContext = asyncTestRunner.isAsyncDeclaration( functionDeclaration );

	"Tester to run a one function execution."
	Tester tester = Tester();
	"init context to perform test initialization."
	InitializerContext initContext = InitializerContext();
	
	
	"Applies function from declaration, container and a given type parameters."
	Function<Anything, Nothing> applyFunction( Type<Anything>* typeParams ) {
		if ( exists container = instance, exists containerType = instanceType ) {
			return functionDeclaration.memberApply<Nothing, Anything, Nothing> (
				containerType, *typeParams ).bind( container );
		}
		else {
			return functionDeclaration.apply<Anything, Nothing>( *typeParams );
		}
	}
	
	"Executes one variant and performs initialization and dispose.
	 Returns output from this variant."
	VariantTestOutput executeVariant (
		TestExecutionContext context, Type<Anything>[] typeParameters, Anything[] args
	) {
		// run initializers firstly
		if ( exists errOut = initContext.run( intializers ) ) {
			// initialization has been failed
			return VariantTestOutput( [errOut], 0, false );
		}
		else {
			// run test
			value testFunction = applyFunction( *typeParameters );
			TestOutput[] output = tester.run (
				( AsyncTestContext context ) {
					if ( runOnAsyncContext ) {
						testFunction.apply( context, *args );
					}
					else {
						// test function doesn't take async context - call it as sync and complete the execution
						testFunction.apply( *args );
						context.complete();
					}
				}
			);
			// run cleaners
			variable TestOutput[] disposeOut = [];
			for ( cleaner in cleaners ) {
				value cleanerOut = tester.run( cleaner );
				if ( !cleanerOut.empty ) {
					disposeOut = disposeOut.append( cleanerOut );
				}
			}
			if ( disposeOut.empty ) {
				// everything is OK
				return VariantTestOutput( output, tester.runInterval, true );
			}
			else {
				// dispose has been failed
				return VariantTestOutput( output.append( disposeOut ), tester.runInterval, false );
			}
		}
	}
	
	"Executes all variants for the given list of argument variants `argsVariants`"
	void executeVariants( TestExecutionContext context, {[Type<Anything>[], Anything[]]*} argsVariants ) {
		variable Integer startTime = system.milliseconds;
		resultEmitter.startEvent( context );
		variable TestState state = TestState.skipped;
		variable Integer index = 1;
		
		// for each argument in collection results are stored as separated test variant
		for ( args in argsVariants ) {
			// execute variant
			VariantTestOutput executionResults = executeVariant( context, args[0], args[1] );
			// fill with test results
			String varName = variantName( args[0], args[1] );
			if ( executionResults.outs.empty ) {
				// test has been succeeded
				resultEmitter.variantResultEvent (
					context,
					TestOutput (
						TestState.success, null, executionResults.totalElapsedTime, "``varName`` - ``TestState.success``"
					),
					index ++
				);
				if ( state < TestState.success ) { state = TestState.success; }
			}
			else {
				// some outputs are available - it doesn't mean the test has been failured!
				for ( variantOutput in executionResults.outs ) {
					String strTitle =	if ( variantOutput.title.empty )
						then " - ``variantOutput.state``"
						else " - ``variantOutput.state``: ``variantOutput.title``";
					resultEmitter.variantResultEvent (
						context,
						TestOutput (
							variantOutput.state, variantOutput.error, variantOutput.elapsedTime, "``varName````strTitle``"
						),
						index ++
					);
					if ( state < variantOutput.state ) { state = variantOutput.state; }
				}
				// initialization or disposing hasbeen failed - stop testing
				if ( !executionResults.proceeded ) { break; }
			}
		}
		resultEmitter.finishEvent (
			context,
			TestResult( context.description, state, true, null, system.milliseconds - startTime ),
			argsVariants.size
		);
	}

	
	shared void runTest() {
		TestExecutionContext context = parent.childContext( description );
		try {
			if ( nonempty conditions = evaluateAnnotatedConditions( functionDeclaration, context ) ) {
				// test has been skipped due to unsatisfying some conditions
				resultEmitter.fillTestResults( context, conditions, 0, 1 );
			}
			else {
				// test parameters - series of arguments
				value argLists = resolveParameterizedList( functionDeclaration );
				Integer size = argLists.size;
				// execute test
				if ( size == 0 ) {
					value res = executeVariant( context, [], [] );
					resultEmitter.fillTestResults( context, res.outs, res.totalElapsedTime, 1 );
				}
				else if ( size == 1, exists args = argLists.first ) {
					value res = executeVariant( context, args[0], args[1] );
					resultEmitter.fillTestResults( context, res.outs, res.totalElapsedTime, 1 );
				}
				else {
					executeVariants( context, argLists );
				}
			}
		}
		catch ( TestSkippedException e ) {
			resultEmitter.startEvent( context );
			resultEmitter.finishEvent( context, TestResult( description, TestState.skipped, false, e ), 0 );
		}
		catch ( Throwable e ) {
			resultEmitter.startEvent( context );
			resultEmitter.finishEvent( context, TestResult( description, TestState.error, false, e ), 0 );
		}
	}
	
	
	"Constructs variant name from type parameters and function arguments."
	String variantName( Type<Anything>[] typeParameters, Anything[] args ) {
		StringBuilder builder = StringBuilder();
		
		// add type parameters
		variable Integer size = typeParameters.size;
		if ( size > 0 ) {
			size --;
			builder.append( "<" );
			for( arg in typeParameters.indexed ) {
				builder.append( arg.item.string );
				if( arg.key < size ) {
					builder.append(", ");
				}
			}
			builder.append( "> " );
		}
		
		// add function arguments
		size = args.size - 1;
		if ( size > 0 ) { builder.append( "with arguments (" ); }
		else { builder.append( "with argument (" ); }
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
