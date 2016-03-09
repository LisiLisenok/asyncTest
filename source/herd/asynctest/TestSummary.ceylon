import ceylon.test {

	TestState
}


"Represents a summary of test group execution."
by( "Lis" )
shared final class TestSummary (
	"The worst state from the all executed test results."
	shared TestState overallState,
	"Overall number of success events."
	shared Integer successes,
	"Overall number of failure events."
	shared Integer failures,
	"Overall number of error events."
	shared Integer errors,
	"Overall number of skip events."
	shared Integer skips,
	"Overall number of abort events."
	shared Integer aborts,
	"Overall number of executions."
	shared Integer executions,
	"Overall time elapsed for test execution in milliseconds."
	shared Integer overallTestTime
) {
	shared actual String string =>
			"test summary: ``overallState``, ``successes`` successes, ``failures`` failures, "
			+ "``errors`` errors, ``skips`` skips, ``aborts`` aborts, ``executions`` total executions, "
			+ "``overallTestTime/1000.0``s elapsed time";
}

