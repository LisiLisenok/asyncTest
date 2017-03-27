import ceylon.test.engine.spi {
	TestExecutionContext
}
import ceylon.test {
	TestState
}

import herd.asynctest.parameterization {
	TestOutput,
	TestVariantResult
}


"Summary result of variant execution."
since( "0.0.1" ) by( "Lis" )
final class VariantTestOutput (
	"Outputs from test initialization." shared TestOutput[] initOutput,	
	"Outputs from test." shared TestOutput[] testOutput,
	"Outputs from test dispose." shared TestOutput[] disposeOutput,
	"Total time in ms elapsed on this test." shared Integer totalElapsedTime,
	"The name of the variant." shared String variantName,
	"Total state of the execution" shared TestState totalState
) {
	
	shared TestVariantResult variantResult => TestVariantResult (
		initOutput.append( testOutput ).append( disposeOutput ),
		totalElapsedTime, totalState
	);
	
	"`true` if `initOutput`, `testOutput` and `disposeOutput` all together are empty and `false` otherwise."
	shared Boolean emptyOutput => initOutput.empty && testOutput.empty && disposeOutput.empty;
	
	string => "``variantName``: ``initOutput.size``, ``testOutput.size``, ``disposeOutput.size``";
}


"Summary result of a one function test execution with different arguments."
since( "0.6.0" ) by( "Lis" )
final class ExecutionTestOutput (
	"Context the test is executed on." shared TestExecutionContext context, 
	"Variants." shared VariantTestOutput[] variants,
	"Time in ms elapsed on theexecution" shared Integer elapsedTime,
	"Total state of the execution" shared TestState state
) {}
