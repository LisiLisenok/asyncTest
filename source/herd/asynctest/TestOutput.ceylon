import ceylon.test {

	TestState
}
import ceylon.test.engine.spi {

	TestExecutionContext
}


"Results of the test execution."
since( "0.0.1" ) by( "Lis" )
final class TestOutput (
	"Final test state." shared TestState state,
	"Error if occured." shared Throwable? error,
	"Total time elapsed on the test." shared Integer elapsedTime,
	"Output title." shared String title
)
{
	string => "``state``: ``title``";
}


"Results of the one run."
since( "0.6.0" ) by( "Lis" )
final class TestFunctionOutput (
	"Outputs from test." shared TestOutput[] testOutput,
	"Total time elapsed on this test." shared Integer totalElapsedTime,
	"Total state of the execution" shared TestState totalState
)
{}

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
	string => "``variantName``: ``initOutput.size``, ``testOutput.size``, ``disposeOutput.size``";
}


"Summary result of a one function test execution with different arguments."
since( "0.6.0" ) by( "Lis" )
final class ExecutionTestOutput (
	"Context the test is executed on." shared TestExecutionContext context, 
	"Variants." shared VariantTestOutput[] variants,
	"Time elapsed on test run" shared Integer elapsedTime,
	"Total state of the execution" shared TestState state
) {
}
