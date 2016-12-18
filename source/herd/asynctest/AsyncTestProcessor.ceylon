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
	findFirstAnnotation,
	extractSourceValue,
	declarationVerifier
}
import herd.asynctest.runner {

	AsyncTestRunner,
	RunWithAnnotation,
	RepeatStrategy,
	repeatOnce
}
import herd.asynctest.parameterization {
	TestVariantEnumerator,
	TestVariant,
	TestVariantProvider
}


"Processes test execution with the branch test generic parameters and function arguments."
since( "0.2.0" ) by( "Lis" )
class AsyncTestProcessor(
	"Test function." FunctionDeclaration testFunctionDeclaration,
	"Object contained function or `null` if function is top level." Object? instance,
	"Test execution context of this function." TestExecutionContext functionContext,
	"Group to run test function, looks for timeout and uncaught exceptions." ContextThreadGroup group,
	"Functions called before each test." PrePostFunction[] intializers,
	"Functions called after each test and may add reportings." TestFunction[] statements,
	"Functions called after each test." PrePostFunction[] cleaners
) {

	"Type of the container instance."
	Type<Object>? instanceType = if ( exists i = instance ) then type( i ) else null;
	
	"Time out for a one function run."
	Integer timeOutMilliseconds = extractTimeout( testFunctionDeclaration );

	"`true` if test function is run on async test context."
	Boolean runOnAsyncContext = declarationVerifier.isAsyncDeclaration( testFunctionDeclaration );
	
	"Init context to perform test initialization."
	PrePostContext prePostContext = PrePostContext( group );
	
	"Tester to execute test + test statements."
	Tester tester = Tester( group );
	
	
	"Resolves a list of type parameters and function arguments provided by annotations satisfied `TestVariantProvider`.  
	 Returns a list of parameters list."
	TestVariantEnumerator resolveParameterizedList() {
		value providers = testFunctionDeclaration.annotations<Annotation>().narrow<TestVariantProvider>();
		if ( providers.empty ) {
			return EmptyTestVariantEnumerator();
		}
		else if ( providers.size == 1 ) {
			return providers.first?.variants( testFunctionDeclaration, instance ) else EmptyTestVariantEnumerator();
		}
		else {
			return CombinedVariantEnumerator( providers*.variants( testFunctionDeclaration, instance ).iterator() );
		}
	}
	
	
	"Extracts test runner from test function annotations."
	AsyncTestRunner? getRunner() =>
			if ( exists ann = findFirstAnnotation<RunWithAnnotation>( testFunctionDeclaration ) )
			then extractSourceValue<AsyncTestRunner>( ann.runner, instance )
			else null;
	
	"Applies function from declaration, container and a given type parameters."
	Function<Anything, Nothing> applyFunction( Type<Anything>* typeParams ) {
		if ( exists container = instance, exists containerType = instanceType ) {
			return testFunctionDeclaration.memberApply<Nothing, Anything, Nothing> (
				containerType, *typeParams ).bind( container );
		}
		else {
			return testFunctionDeclaration.apply<Anything, Nothing>( *typeParams );
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
			timeOutMilliseconds, testFunctionDeclaration.name
		);
	}
	
	
	"Returns test repeat strategy from [[retry]] annotation."
	RepeatStrategy getRepeatStrategy() =>
			if ( exists ann = findFirstAnnotation<RetryAnnotation>( testFunctionDeclaration ) )
			then extractSourceValue<RepeatStrategy>( ann.source, instance )
			else repeatOnce;
	
		
	"Executes one variant and performs initialization and dispose.
	 Returns output from this variant."
	VariantTestOutput executeVariant( TestVariant variant ) {
		TestInfo testInfo = TestInfo (
			testFunctionDeclaration, variant.parameters, variant.arguments, variant.variantName, timeOutMilliseconds
		);
		// test with next ID is started
		group.incrementTestID();
		// run initializers firstly
		if ( nonempty initErrs = prePostContext.run( intializers, testInfo ) ) {
			// initialization has been failed
			// run disposing, complete test variant and return results
			value disposeErrs = prePostContext.run( cleaners, testInfo );
			return VariantTestOutput( initErrs, [], disposeErrs, 0, variant.variantName, TestState.aborted );
		}
		else {
			// run test + statements
			TestVariantResult output = tester.run( getTestFunction( variant ), statements, testInfo, getRunner() );
			// run cleaners
			value disposeErrs = prePostContext.run( cleaners, testInfo );
			return VariantTestOutput (
				[], output.testOutput, disposeErrs, output.overallElapsedTime, variant.variantName, output.overallState
			);
		}
	}
	
	"Executes all variants for the given list of test variants (`parameters`)."
	ExecutionTestOutput executeVariants( TestExecutionContext context, TestVariantEnumerator testParameters ) {
		variable Integer startTime = system.nanoseconds;
		variable TestState state = TestState.skipped;
		ArrayList<VariantTestOutput> variants = ArrayList<VariantTestOutput>();
		
		// for each argument in collection results are stored as separated test variant
		while ( is TestVariant variant = testParameters.current ) {
			// strategy for test repeating, asking before each variant
			// since factory function is preferable in multithread environment
			RepeatStrategy repeat = getRepeatStrategy(); 
		 	// execute current variant
		 	variable VariantTestOutput executionResults = executeVariant( variant );
		 	while ( !repeat.completeOrRepeat( executionResults.variantResult ) exists ) {
		 		executionResults = executeVariant( variant );
		 	}
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
		
		return ExecutionTestOutput( context, variants.sequence(), (system.nanoseconds - startTime) / 1000000, state );
	}

	
	"Runs the test of a one function inlucding parameterization."
	shared ExecutionTestOutput runTest() {
		try {
			if ( exists condition = evaluateAnnotatedConditions( testFunctionDeclaration, functionContext ) ) {
				// test has been skipped due to unsatisfying some conditions
				return ExecutionTestOutput (
					functionContext,
					[VariantTestOutput( [condition], [], [], 0, "", TestState.skipped )],
					0, TestState.skipped
				);
			}
			else {
				// execute test with the given number of test variants
				return executeVariants( functionContext, resolveParameterizedList() );
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
