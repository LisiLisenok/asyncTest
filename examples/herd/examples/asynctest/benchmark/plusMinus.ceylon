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
			Options(LocalIterations(50000).or(LocalError(0.001)), LocalIterations(5000).or(LocalError(0.001))),
			[SingleBench("plus", plusBenchmarkFunction),
			SingleBench("minus", minusBenchmarkFunction)],
			[1, 1], [2, 3], [25, 34]
		)
	);
	context.complete();
}
