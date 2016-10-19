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


"Processes test execution."
by( "Lis" )
class AsyncTestProcessor(
	"Emitting test results to." TestEventEmitter resultEmitter,
	"Test function." FunctionDeclaration functionDeclaration,
	"Object contained function or `null` if function is top level" Object? instance,
	"Parent execution context." TestExecutionContext parent,
	"Description the test performed on." TestDescription description
)
		satisfies RunnableTestContext
{
	
	"Executes one variant.
	 Returns output from this variant."
	VariantTestOutput executeVariant( TestExecutionContext context, Anything[] args ) {
		// run test
		Tester tester = Tester();
		value output = tester.run( functionDeclaration, instance, *args );
		// test results
		return VariantTestOutput( output, tester.runInterval );
	}
	
	
	"Executes all variants for the given list of argument variants `argsVariants`"
	void executeVariants( TestExecutionContext context, {Anything[]*} argsVariants ) {
		variable Integer startTime = system.milliseconds;
		resultEmitter.startEvent( context );
		variable TestState state = TestState.skipped;
		variable Integer index = 1;
		for ( args in argsVariants ) {
			// for each argument in collection results are stored as separated test variant
			value executionResults = executeVariant( context, args );
			String varName = variantName( args );
			if ( executionResults.outs.empty ) {
				// test has been succeeded
				resultEmitter.variantResultEvent (
					context,
					TestOutput (
						TestState.success,
						null,
						executionResults.totalElapsedTime,
						"``varName`` - ``TestState.success``"
					),
					index ++
				);
				if ( state < TestState.success ) { state = TestState.success; }
			}
			else {
				// ome outputs are available - it doesn't mean the test has been failured!
				for ( variantOutput in executionResults.outs ) {
					String strTitle =	if ( variantOutput.title.empty )
					then " - ``variantOutput.state``"
					else " - ``variantOutput.state``: ``variantOutput.title``";
					resultEmitter.variantResultEvent (
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
		resultEmitter.finishEvent (
			context,
			TestResult( context.description, state, true, null, system.milliseconds - startTime ),
			argsVariants.size
		);
	}

	
	shared actual void runTest() {
		TestExecutionContext context = parent.childContext( description );
		try {
			if ( nonempty conditions = evaluateAnnotatedConditions( functionDeclaration, context ) ) {
				// test has been skipped due to unsatisfying some conditions
				variable TestState state = TestState.skipped;
				variable Integer index = 1;
				resultEmitter.startEvent( context );
				for ( outErr in conditions ) {
					resultEmitter.variantResultEvent( context, outErr, index ++ );
					if ( state < outErr.state ) { state = outErr.state; }
				}
				resultEmitter.finishEvent( context, TestResult( context.description, state, true, null, 0 ), 0 );
			}
			else {
				// test parameters - series of arguments
				value argLists = resolveArgumentList( functionDeclaration );
				Integer size = argLists.size;
				// execute test
				if ( size == 0 ) {
					value res = executeVariant( context, [] );
					resultEmitter.fillTestResults( context, res.outs, res.totalElapsedTime, 1 );
				}
				else if ( size == 1, exists args = argLists.first ) {
					value res = executeVariant( context, args );
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
