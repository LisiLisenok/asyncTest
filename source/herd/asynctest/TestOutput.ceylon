import ceylon.test {

	TestState
}
import ceylon.test.engine.spi {

	TestExecutionContext
}


"Represents a one report."
since( "0.0.1" ) by( "Lis" )
shared final class TestOutput (
	"Test state of this report." shared TestState state,
	"Error if occured." shared Throwable? error,
	"Time in milliseconds elapsed before reporting." shared Integer elapsedTime,
	"Output title." shared String title
) {
	string => "``state``: ``title``";
}


"Results of a one test function run with some arguments."
since( "0.6.0" ) by( "Lis" )
shared final class TestVariantResult (
	"Outputs from test." shared TestOutput[] testOutput,
	"Overall time in milliseconds elapsed on this test." shared Integer overallElapsedTime,
	"Overall state of the execution." shared TestState overallState
) {
	string => "``overallState`` at ``overallElapsedTime``ms.";
}


"Summary result of variant execution."
since( "0.0.1" ) by( "Lis" )
final class VariantTestOutput (
	"Outputs from test initialization." shared TestOutput[] initOutput,	
	"Outputs from test." shared TestOutput[] testOutput,
	"Outputs from test dispose." shared TestOutput[] disposeOutput,
	"Total time elapsed on this test." shared Integer totalElapsedTime,
	"The name of the variant." shared String variantName,
	"Total state of the execution" shared TestState totalState
) {
	
	"`true` if `initOutput`, `testOutput` and `disposeOutput` all together are empty and `false` otherwise."
	shared Boolean emptyOutput => initOutput.empty && testOutput.empty && disposeOutput.empty;
	
	string => "``variantName``: ``initOutput.size``, ``testOutput.size``, ``disposeOutput.size``";
}


"Summary result of a one function test execution with different arguments."
since( "0.6.0" ) by( "Lis" )
final class ExecutionTestOutput (
	"Context the test is executed on." shared TestExecutionContext context, 
	"Variants." shared VariantTestOutput[] variants,
	"Time elapsed on test run" shared Integer elapsedTime,
	"Total state of the execution" shared TestState state
) {}
