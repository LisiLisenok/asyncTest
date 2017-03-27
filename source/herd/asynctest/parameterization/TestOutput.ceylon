import ceylon.test {

	TestState
}


"Represents a one test report."
tagged( "Base" )
see( `class TestVariantResult` )
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
tagged( "Base" )
see( `interface TestVariantEnumerator` )
since( "0.6.0" ) by( "Lis" )
shared final class TestVariantResult (
	"Outputs from test." shared TestOutput[] testOutput,
	"Overall time in milliseconds elapsed on the test run." shared Integer overallElapsedTime,
	"Overall state of the test run." shared TestState overallState
) {
	string => "``overallState`` at ``overallElapsedTime``ms.";
}
