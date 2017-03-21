import herd.asynctest {
	async,
	AsyncTestContext
}
import herd.asynctest.benchmark {
	NumberOfLoops,
	benchmark,
	Options,
	RandomFlow,
	SingleBench
}
import ceylon.test {
	test
}
import herd.asynctest.match {
	CloseTo
}


shared class RandomTestFunction() {
	
	
	variable Integer f1Calls = 0;
	variable Integer f2Calls = 0;
	variable Integer f3Calls = 0;
	
	void f1() => f1Calls ++;
	void f2() => f2Calls ++;
	void f3() => f3Calls ++;
	
	
	shared async test void selectFunctionRandomly(AsyncTestContext context) {
		benchmark (
			Options(NumberOfLoops(1000), NumberOfLoops(100)),
			[
				SingleBench (
					"random test function",
					RandomFlow(1, [f1, 0.3], [f2, 0.2], [f3, 0.5])
				)
			]
		);
		Integer sum = f1Calls + f2Calls + f3Calls;
		context.assertThat((f1Calls.float/sum*100+0.5).integer, CloseTo(30, 2), "first function % of calls", true);
		context.assertThat((f2Calls.float/sum*100+0.5).integer, CloseTo(20, 2), "second function % of calls", true);
		context.assertThat((f3Calls.float/sum*100+0.5).integer, CloseTo(50, 2), "third function % of calls", true);
		context.complete();
	}
	
}

