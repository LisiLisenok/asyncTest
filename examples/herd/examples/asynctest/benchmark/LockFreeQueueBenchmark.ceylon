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
	MultiBench,
	TimeUnit,
	CPUClock
}


"[[LockFreeQueue]] multithread producer-consumer benchmark."
shared test async void lockFreeQueueProducerConsumer(AsyncTestContext context) {
	// queue to test
	LockFreeQueue<Integer> queue = LockFreeQueue<Integer>();
	for ( i in 0 : 100 ) { queue.enqueue( 1 ); }
	
	writeRelativeToFastest (
		context,
		benchmark (
			Options(NumberOfLoops(500), NumberOfLoops(100), 100, TimeUnit.milliseconds, CPUClock),
			[
				MultiBench(
					"producer-consumer",
					() => queue.enqueue( 1 ),
					queue.dequeue
				)
			],
			[1, 1], [2, 1], [1, 2], [2, 2]
		)
	);
	context.complete();
}
