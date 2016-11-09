import herd.asynctest {
	AsyncPrePostContext
}


"Collects statistic data on an execution time and on a rate (per second) at which a set of events occur.  
 Statistic data is reset before _each_ test.  
 To start recording call [[start]]. To record time delta call [[tick]] which records time delta
 from `start` or previous `tick` and up to now.  
 
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
 			print(meterRule.rateStatistic);
 		}
 
 "
see( `class StatisticSummary` )
by( "Lis" ) since( "0.6.0" )
shared class MeterRule() satisfies TestRule
{
	
	"Calculations of the time statistic data."
	StatisticCalculator timeCalculator = StatisticCalculator();
	
	"Calculations of the rate of operations per second statistic data."
	StatisticCalculator rateCalculator = StatisticCalculator();
	
	"Time from previous tick."
	variable Integer previousTime = -1;


	"Statistic summary for execution time."
	shared StatisticSummary timeStatistic => timeCalculator.statisticSummary;
	
	"Statistic summary for rate (operations per second)."
	shared StatisticSummary rateStatistic => rateCalculator.statisticSummary;
	
	
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
		rateCalculator.sample( 1000000000.0 / delta );
	}
	
	
	shared actual void after( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void before( AsyncPrePostContext context ) {
		previousTime = -1;
		timeCalculator.reset();
		rateCalculator.reset();
		context.proceed();
	}
	
}