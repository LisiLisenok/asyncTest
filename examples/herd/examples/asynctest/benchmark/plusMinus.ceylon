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
	NumberOfLoops,
	Options,
	SingleBench,
	ErrorCriterion
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
			Options(NumberOfLoops(1000).or(ErrorCriterion(0.002)), NumberOfLoops(100).or(ErrorCriterion(0.002))),
			[SingleBench("plus", plusBenchmarkFunction),
			SingleBench("minus", minusBenchmarkFunction)],
			[1, 1], [2, 3], [25, 34]
		)
	);
	context.complete();
}
