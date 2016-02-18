import ceylon.test {

	TestState
}


"results of the test"
by( "Lis" )
class TestOutput (
	shared TestState state,
	shared Throwable? error,
	shared Integer elapsedTime,
	shared String title,
	shared String preamble = ""
)
{}
