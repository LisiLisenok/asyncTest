import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import ceylon.test {

	TestState,
	TestDescription
}

import ceylon.language.meta.model {

	Type,
	Function
}
import ceylon.language.meta {

	type
}
import ceylon.collection {

	ArrayList
}
import ceylon.test.engine {

	TestSkippedException
}
import herd.asynctest.internal {

	stringify,
	typeName
}


"Processes test execution with the branch test generic parameters and function arguments."
since( "0.2.0" )
by( "Lis" )
class AsyncTestProcessor(
	"Test function." FunctionDeclaration functionDeclaration,
	"Object contained function or `null` if function is top level" Object? instance,
	"Parent execution context." TestExecutionContext parent,
	"Description the test performed on." TestDescription description,
	"Functions called before each test." PrePostFunction[] intializers,
	"Functions called after each test and may add reportings." TestFunction[] statements,
	"Functions called after each test." PrePostFunction[] cleaners,
	"Time out for a one function run" Integer timeOutMilliseconds
) {

	Type<Object>? instanceType = if ( exists i = instance ) then type( i ) else null;

	"`true` if test function is run on async test context."
	Boolean runOnAsyncContext = asyncTestRunner.isAsyncDeclaration( functionDeclaration );

	"Tester to run a one function execution."
	Tester tester = Tester();
	"Init context to perform test initialization."
	PrePostContext prePostContext = PrePostContext();
	
	
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
		if ( nonempty initErrs = prePostContext.run( intializers ) ) {
			// initialization has been failed
			// run disposing and return results
			value disposeErrs = prePostContext.run( cleaners );
			return VariantTestOutput( initErrs, [], disposeErrs, 0, variantName( typeParameters, args ), TestState.aborted );
		}
		else {
			// run test
			value testFunction = applyFunction( *typeParameters );
			TestFunctionOutput output = tester.run (
				TestFunction (
					( AsyncTestContext context ) {
						if ( runOnAsyncContext ) {
							testFunction.apply( context, *args );
						}
						else {
							// test function doesn't take async context - call it as sync and complete the execution
							testFunction.apply( *args );
							context.complete();
						}
					},
					timeOutMilliseconds, functionDeclaration.name
				)
			);
			// run test statements which may add something to the test
			value statementOuts = [ for ( statement in statements ) tester.run( statement ) ];
			variable Integer totalElapsedTime = output.totalElapsedTime;
			variable TestState totalState = output.totalState;
			for ( item in statementOuts ) {
				totalElapsedTime += item.totalElapsedTime;
				if ( totalState < item.totalState ) { totalState = item.totalState; }
			}
			value variantOuts = output.testOutput.append( concatenate( *statementOuts*.testOutput ) );
			// run cleaners
			value disposeErrs = prePostContext.run( cleaners );
			String varName = variantName( typeParameters, args );
			if ( !disposeErrs.empty && variantOuts.empty ) {
				return VariantTestOutput (
					[], [TestOutput( totalState, null, totalElapsedTime, "" )],
					disposeErrs, totalElapsedTime, varName, totalState
				);
			}
			else {
				return VariantTestOutput (
					[], variantOuts, disposeErrs, totalElapsedTime, varName, totalState
				);
			}
		}
	}
	
	"Executes all variants for the given list of argument variants `argsVariants`"
	ExecutionTestOutput executeVariants( TestExecutionContext context, {[Type<Anything>[], Anything[]]*} argsVariants ) {
		variable Integer startTime = system.milliseconds;
		variable TestState state = TestState.skipped;
		ArrayList<VariantTestOutput> variants = ArrayList<VariantTestOutput>();
		 
		// for each argument in collection results are stored as separated test variant
		for ( args in argsVariants ) {
			// execute variant
			value executionResults = executeVariant( context, args[0], args[1] );
			// adds report if container or function is not marked with hideReport 
			variants.add( executionResults );
			if ( state < executionResults.totalState ) { state = executionResults.totalState; }
			// initialization or disposing has been failed - stop testing
			if ( !executionResults.disposeOutput.empty || !executionResults.initOutput.empty ) { break; }
		}
		
		return ExecutionTestOutput( context, variants.sequence(), system.milliseconds - startTime, state );
	}

	
	"Runs the test of a one function inlucding parameterization."
	shared ExecutionTestOutput runTest() {
		TestExecutionContext context = parent.childContext( description );
		try {
			if ( nonempty conditions = evaluateAnnotatedConditions( functionDeclaration, context ) ) {
				// test has been skipped due to unsatisfying some conditions
				return ExecutionTestOutput (
					context,
					[VariantTestOutput( conditions, [], [], 0, "", TestState.skipped )],
					0, TestState.skipped
				);
			}
			else {
				// test parameters - series of arguments
				value argLists = resolveParameterizedList( functionDeclaration );
				Integer size = argLists.size;
				// execute test
				if ( size == 0 ) {
					// just a one variant without arguments
					value variantResults = executeVariant( context, [], [] );
					return ExecutionTestOutput (
						context, [variantResults],
						variantResults.totalElapsedTime, variantResults.totalState
					);
				}
				else if ( size == 1, exists args = argLists.first ) {
					// just a one variant with some arguments
					value variantResults = executeVariant( context, args[0], args[1] );
					return ExecutionTestOutput (
						context, [variantResults],
						variantResults.totalElapsedTime, variantResults.totalState
					);
				}
				else {
					// a number of variants
					return executeVariants( context, argLists );
				}
			}
		}
		catch ( TestSkippedException e ) {
			return ExecutionTestOutput (
				context, [ VariantTestOutput( [ TestOutput( TestState.skipped, e, 0, "" ) ],
						[], [], 0, "", TestState.skipped ) ],
				0, TestState.skipped
			);
			
		}
		catch ( Throwable e ) {
			return ExecutionTestOutput (
				context, [ VariantTestOutput( [ TestOutput( TestState.error, e, 0, "" ) ],
					[], [], 0, "", TestState.error ) ],
				0, TestState.error
			);
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
				builder.append( typeName( arg.item ) );
				if( arg.key < size ) {
					builder.append(", ");
				}
			}
			builder.append( ">" );
		}
		
		// add function arguments
		size = args.size - 1;
		if ( size > -1 ) {
			builder.append( "(" );
			for( arg in args.indexed ) {
				builder.append( stringify( arg.item ) );
				if( arg.key < size ) {
					builder.append(", ");
				}
			}
			builder.append( ")" );
		}
		return builder.string;
	}
	
}
