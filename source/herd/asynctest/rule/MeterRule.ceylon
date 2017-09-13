import herd.asynctest {
	AsyncPrePostContext
}
import java.util.concurrent.atomic {
	AtomicLong
}
import herd.asynctest.benchmark {
	Statistic
}
import herd.asynctest.internal {
	StatisticCalculator
}


"Lock-free and thread-safely collects statistic data on an execution time and on a rate (per second)
 at which a set of events occur.  
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
see( `interface Statistic` )
since( "0.6.0" ) by( "Lis" )
tagged( "TestRule" ) shared class MeterRule() satisfies TestRule
{
	
	class Box() {
		"Calculations of the time statistic data."
		shared StatisticCalculator timeCalculator = StatisticCalculator();
		"Calculations of the rate of operations per second statistic data."
		shared StatisticCalculator rateCalculator = StatisticCalculator();
		"Time from previous tick."
		shared AtomicLong previousTime = AtomicLong( -1 );
		
		string => "meter rule";
	}
	
	CurrentTestStore<Box> store = CurrentTestStore<Box>( Box ); 
	

	"Statistic summary for execution time."
	shared Statistic timeStatistic => store.element.timeCalculator.statisticSummary;
	
	"Statistic summary for rate (operations per second)."
	shared Statistic rateStatistic => store.element.rateCalculator.statisticSummary;
	
	
	"Starts metering from now and memoizes current system time.  
	 To add sample to the statistics data - call [[tick]]."
	see( `function tick` )
	shared void start() => store.element.previousTime.set( system.nanoseconds );
	
	"Adds `numberOfTicks` meter samples from previous `tick` or from `start`.  
	 [[start]] has to be called before the first call of `tick`.  
	 in order to start again call `start` again.  
	 Meter samples are:  
	 * Time spent from previous `tick` call divided by `numberOfTicks`, i.e. mean time required by a one event.
	   Added to [[timeStatistic]].  
	 * Rate i.e. number of events per time occured from previous `tick` call.
	   Number of events is equal to `numberOfTicks`. Added to [[rateStatistic]].  
	 "
	throws ( `class AssertionError`, "If called before `start`." )
	see( `function start`, `value timeStatistic`, `value rateStatistic` )
	shared void tick( "Number of ticks. To be > 0." Integer numberOfTicks = 1 ) {
		"MeterRule: calling `tick` before `start`."
		assert ( store.element.previousTime.get() >= 0 );
		"MeterRule: number of ticks has to be > 0."
		assert ( numberOfTicks > 0 );
		
		Box box = store.element;
		Integer now = system.nanoseconds;
		Integer delta = system.nanoseconds - box.previousTime.getAndSet( now );
		if ( delta > 0 ) {
			box.timeCalculator.sample( delta / 1000000.0 / numberOfTicks );
			box.rateCalculator.sample( 1000000000.0 / delta * numberOfTicks );
		}
	}
	
	
	shared actual void after( AsyncPrePostContext context ) => store.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => store.before( context );
	
}
