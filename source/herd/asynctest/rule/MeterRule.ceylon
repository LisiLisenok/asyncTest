import herd.asynctest {
	AsyncPrePostContext
}


"Collects statistic data on execution time and number of operations per second.  s
 Statistic data is reset before _each_ test.  
 To start recording call [[start]]. To record time delta call [[tick]] which records time delta
 from start or previous `tick` calling and up to now.  
 
 Example:
 
 		MeterRule meterRule = MeterRule();
 		...
 		void benchTest() {
 			meterRule.start();
 			for (repeat in 0..repeatCounts) {
 				doOperation();
 				meterRule.tick();
 			}
 			print(meterRule.timeStatistic);
 			print(meterRule.opsStatistic);
 		}
 
 "
see( `class StatisticSummary` )
by( "Lis" ) since( "0.6.0" )
shared class MeterRule() satisfies TestRule
{
	
	"Calculations of the time statistic data."
	StatisticCalculator timeCalculator = StatisticCalculator();
	
	"Calculations of the operations per second statistic data."
	StatisticCalculator opsCalculator = StatisticCalculator();
	
	"Time from previous tick."
	variable Integer previousTime = -1;


	"Statistic summary for execution time."
	shared StatisticSummary timeStatistic => timeCalculator.statisticSummary;
	
	"Statistic summary for operations per second."
	shared StatisticSummary opsStatistic => opsCalculator.statisticSummary;
	
	
	"Starts benchmarking from now and memoizes current system time.  
	 To add sample to the statistics data - call [[tick]]."
	see( `function tick` )
	shared void start() => previousTime = system.nanoseconds;
	
	"Adds clock sample from previous `tick` or from `start`.  
	 [[start]] has to be called before the first call of `tick`.  
	 in order to start again call `start` again."
	throws ( `class AssertionError`, "If called before `start`." )
	see( `function start` )
	shared void tick() {
		"BenchmarkRule: calling `tick` before `start`."
		assert ( previousTime >= 0 );
		
		Integer now = system.nanoseconds;
		Integer delta = now - previousTime;
		previousTime = now;
		timeCalculator.sample( delta / 1000000.0 );
		opsCalculator.sample( 1000000000.0 / delta );
	}
	
	
	shared actual void after( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void before( AsyncPrePostContext context ) {
		previousTime = -1;
		timeCalculator.reset();
		opsCalculator.reset();
		context.proceed();
	}
	
}
