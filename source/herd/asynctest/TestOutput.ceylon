import ceylon.test {

	TestState
}


"Results of the test execution."
since( "0.0.1" )
by( "Lis" )
final class TestOutput (
	"Final test state." shared TestState state,
	"Error if occured." shared Throwable? error,
	"Total time elapsed on the test." shared Integer elapsedTime,
	"Output title." shared String title
)
{}
