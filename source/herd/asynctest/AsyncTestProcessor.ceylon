import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import ceylon.test {

	TestState
}

import ceylon.language.meta.model {

	Type,
	Function
}
import ceylon.collection {

	ArrayList
}
import ceylon.test.engine {

	TestSkippedException
}
import ceylon.language.meta {
	
	type
}
import herd.asynctest.internal {

	ContextThreadGroup,
	findFirstAnnotation
}
import herd.asynctest.runner {

	AsyncTestRunner,
	RunWithAnnotation
}


"Processes test execution with the branch test generic parameters and function arguments."
since( "0.2.0" ) by( "Lis" )
class AsyncTestProcessor(
	"Test function." FunctionDeclaration functionDeclaration,
	"Object contained function or `null` if function is top level." Object? instance,
	"Test execution context of this function." TestExecutionContext functionContext,
	"Functions called before each test." PrePostFunction[] intializers,
	"Functions called after each test and may add reportings." TestFunction[] statements,
	"Functions called after each test." PrePostFunction[] cleaners
) {

	"Type of the container instance."
	Type<Object>? instanceType = if ( exists i = instance ) then type( i ) else null;
	
	"Time out for a one function run."
	Integer timeOutMilliseconds = extractTimeout( functionDeclaration );

	"`true` if test function is run on async test context."
	Boolean runOnAsyncContext = asyncTestRunner.isAsyncDeclaration( functionDeclaration );
	
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group = ContextThreadGroup( "asyncTester" );

	"Init context to perform test initialization."
	PrePostContext prePostContext = PrePostContext( group );
	
	
	"Extracts test runner from test function annotations."
	AsyncTestRunner? getRunner() =>
			if ( exists ann = findFirstAnnotation<RunWithAnnotation>( functionDeclaration ) )
			then extractSourceValue<AsyncTestRunner>( ann.runner, instance )
			else null;
	
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
	
	"Returns test function to be run for the given test variant."
	TestFunction getTestFunction( TestVariant variant ) {
		value testFunction = applyFunction( *variant.parameters );
		return TestFunction (
			( AsyncTestContext context ) {
				if ( runOnAsyncContext ) {
					testFunction.apply( context, *variant.arguments );
				}
				else {
					// test function doesn't take async context - call it as sync and complete the execution
					testFunction.apply( *variant.arguments );
					context.complete();
				}
			},
			timeOutMilliseconds, functionDeclaration.name
		);
	}
	
	"Executes one variant and performs initialization and dispose.
	 Returns output from this variant."
	VariantTestOutput executeVariant( TestVariant variant ) {
		// run initializers firstly
		TestInfo testInfo = TestInfo (
			functionDeclaration, variant.parameters, variant.arguments, variant.variantName, timeOutMilliseconds
		);
		if ( nonempty initErrs = prePostContext.run( intializers, testInfo ) ) {
			// initialization has been failed
			// run disposing, complete test variant and return results
			value disposeErrs = prePostContext.run( cleaners, testInfo );
			return VariantTestOutput( initErrs, [], disposeErrs, 0, variant.variantName, TestState.aborted );
		}
		else {
			// run test
			TestVariantResult output = Tester( group, getTestFunction( variant ), testInfo ).run( getRunner() );
			
			// run test statements which may add something to the test report
			value statementOuts = [ for ( statement in statements ) Tester( group, statement, testInfo ).run() ];
			variable TestState totalState = output.overallState;
			for ( item in statementOuts ) {
				if ( totalState < item.overallState ) { totalState = item.overallState; }
			}
			value variantOuts = output.testOutput.append( concatenate( *statementOuts*.testOutput ) );
			
			// run cleaners
			value disposeErrs = prePostContext.run( cleaners, testInfo );
			if ( !disposeErrs.empty && variantOuts.empty ) {
				return VariantTestOutput (
					[], [TestOutput( totalState, null, output.overallElapsedTime, "" )],
					disposeErrs, output.overallElapsedTime, variant.variantName, totalState
				);
			}
			else {
				return VariantTestOutput (
					[], variantOuts, disposeErrs, output.overallElapsedTime, variant.variantName, totalState
				);
			}
		}
	}
	
	"Executes all variants for the given list of test variants (`parameters`)."
	ExecutionTestOutput executeVariants( TestExecutionContext context, TestVariantEnumerator testParameters ) {
		variable Integer startTime = system.milliseconds;
		variable TestState state = TestState.skipped;
		ArrayList<VariantTestOutput> variants = ArrayList<VariantTestOutput>();
		
		// for each argument in collection results are stored as separated test variant
		while ( is TestVariant variant = testParameters.current ) {
		 	// execute current variant
		 	value executionResults = executeVariant( variant );
		 	// store results
			variants.add( executionResults );
			// check total state
			if ( state < executionResults.totalState ) {
				state = executionResults.totalState;
			}
			if ( executionResults.disposeOutput.empty && executionResults.initOutput.empty ) {
				// move to next test variant
				testParameters.moveNext ( TestVariantResult (
					executionResults.testOutput, executionResults.totalElapsedTime, executionResults.totalState
				) );
			}
			else {
				// initialization or disposing has been failed - stop testing
				break;
			}
		}
		
		return ExecutionTestOutput( context, variants.sequence(), system.milliseconds - startTime, state );
	}

	
	"Runs the test of a one function inlucding parameterization."
	shared ExecutionTestOutput runTest() {
		try {
			if ( exists condition = evaluateAnnotatedConditions( functionDeclaration, functionContext ) ) {
				// test has been skipped due to unsatisfying some conditions
				return ExecutionTestOutput (
					functionContext,
					[VariantTestOutput( [condition], [], [], 0, "", TestState.skipped )],
					0, TestState.skipped
				);
			}
			else {
				// test parameters - series of arguments
				value argEnumerator = resolveParameterizedList( functionDeclaration, instance );
				// execute test
				return executeVariants( functionContext, argEnumerator );
			}
		}
		catch ( TestSkippedException e ) {
			return ExecutionTestOutput (
				functionContext, [ VariantTestOutput( [ TestOutput( TestState.skipped, e, 0, "" ) ],
						[], [], 0, "", TestState.skipped ) ],
				0, TestState.skipped
			);
			
		}
		catch ( Throwable e ) {
			return ExecutionTestOutput (
				functionContext, [ VariantTestOutput( [ TestOutput( TestState.error, e, 0, "" ) ],
					[], [], 0, "", TestState.error ) ],
				0, TestState.error
			);
		}
		finally { group.completeCurrent(); }
	}
	
}
