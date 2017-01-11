import ceylon.test {

	test
}
import herd.asynctest {

	async,
	AsyncTestContext
}
import herd.asynctest.benchmark {

	writeRelativeToFastest,
	benchmark,
	LocalIterations,
	Options,
	SingleBench,
	LocalError
}


Integer plusBenchmarkFunction(Integer x, Integer y) {
	return x + y;
}
Integer minusBenchmarkFunction(Integer x, Integer y) {
	return x - y;
}

shared test async void plusMinusBenchmark(AsyncTestContext context) {
	writeRelativeToFastest (
		context,
		benchmark (
			Options(LocalIterations(20000).or(LocalError(0.002)), LocalIterations(1000).or(LocalError(0.01))),
			[SingleBench("plus", plusBenchmarkFunction),
			SingleBench("minus", minusBenchmarkFunction)],
			[1, 1], [2, 3], [25, 34]
		)
	);
	context.complete();
}
