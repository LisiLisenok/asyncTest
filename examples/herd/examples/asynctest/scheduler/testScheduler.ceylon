import herd.asynctest {

	AsyncTestContext,
	TestInitContext,
	init,
	AsyncTestExecutor
}
import ceylon.test {

	parameters,
	test,
	testExecutor
}


"Test initializer parameters."
see( `function initScheduler` )
shared [String, Integer] initParams => ["scheduler", 2];


"Iinitializes scheduler and puts it to init context with name [[schedulerName]]."
parameters( `value initParams` )
see( `class Scheduler`, `function testScheduler` )
shared void initScheduler (
	"Initialization context to store some data." TestInitContext context,
	"Name to store scheduler under." String schedulerName,
	"Argument of [[Scheduler]]" Integer corePoolSize
) {
	// instantiate scheduler
	Scheduler scheduler = Scheduler( corePoolSize );
	// store scheduler on the context
	context.put (
		schedulerName,
		scheduler,
		scheduler.stopAll
	);
	// asks context to continue with testing
	context.proceed();
}


shared {[String, {{Integer*}*}, Integer]*} oneConstantTimer
		=> {["scheduler", {{250}.repeat( 7 )}, 20]};
shared {[String, {{Integer*}*}, Integer]*} oneDoubleTimer
		=> {["scheduler", {{250, 350}.repeat( 5 )}, 20]};
shared {[String, {{Integer*}*}, Integer]*} oneTripleTimer
		=> {["scheduler", {{250, 450, 200}.repeat( 4 )}, 20]};
shared {[String, {{Integer*}*}, Integer]*} oneIncreasingTimer
		=> {["scheduler", {{250, 400, 450, 600, 820, 900}}, 20]};
shared {[String, {{Integer*}*}, Integer]*} twoConstantTimers
		=> {["scheduler", {{250}.repeat( 7 ), {350}.repeat( 6 )}, 20]};
shared {[String, {{Integer*}*}, Integer]*} twoDoubleTimers
		=> {["scheduler", {{250, 350}.repeat( 7 ), {350, 280}.repeat( 6 )}, 20]};
shared {[String, {{Integer*}*}, Integer]*} threeConstantTimers
		=> {["scheduler", {{250}.repeat( 7 ), {350}.repeat( 6 ), {300}.repeat( 5 )}, 20]};
shared {[String, {{Integer*}*}, Integer]*} threeDoubleTimers
		=> {["scheduler", {{250, 350}.repeat( 7 ), {400, 350}.repeat( 4 ), {350, 280}.repeat( 6 )}, 20]};

"Scheduler test parameters."
shared {[String, {{Integer*}*}, Integer]*} combinedTimers
		=> oneConstantTimer.chain( oneDoubleTimer ).chain( oneTripleTimer ).chain( oneIncreasingTimer )
			.chain( twoConstantTimers ).chain( twoDoubleTimers ).chain( threeConstantTimers ).chain( threeDoubleTimers );


"Performs scheduler test.   
 
 Expects scheduler has been initialized and available from test context with name [[schedulerName]].  
 
 ####Annotations:
 * `test` - asks Ceylon test tool to run this function
 * `testExecutor` - asks to run this test using executor provided by the annotation argument
 * `init` - asks to perform initialization using initializer provided by the annotation argument,
   initialization is performed just once for every test function execution
 * `parameter` - asks to perform test using parameters provided by the annotation argument
 
 
 ####Test procedure:
 1. Retrieving scheduler from context using [[schedulerName]].
 2. Scheduling timers according to [[delayList]], where each item represents a timer.
 3. Listening timers on fire, completion and erroring (see [[Scheduler.schedule]]).
 
 ####Possible failures:
 1. Delay the timer fires with has to be close to expected one (item from timer `delays`) with give `tolerance`.
 2. Total timer time has to be close to expected one (sum of timer delays) with give `tolerance`.
 3. Timer reports on error (see [[Scheduler.schedule]].
 4. Timer is exhausted with total fires not equal to size of timer `delays`.
 
 ####Tolerance
 By nature timer can fire a little bit lately than specified. Also some time may be spent to deliver timer fire to listener.
 So measured timer delay may be greater than expected one. To take into account these statements tolerance is used to compare
 timer actual delays and timer total time with expected ones.
 
 "
test
testExecutor( `class AsyncTestExecutor` )
init( `function initScheduler` )
parameters( `value combinedTimers` )
shared void testScheduler (
	"Context the test is performed on." AsyncTestContext context,
	"Name of the scheduler to be retrieved from [[context]]." String schedulerName,
	"List of delays submited to [[Scheduler.schedule]]." {{Integer*}*} delayList,
	"Tolerance used to compare actual and expected delays, to be >= 0." Integer tolerance
) {
	"Scheduler hasn't been innitialized or stored with appropriate name!"
	assert ( exists scheduler = context.get<Scheduler>( schedulerName ) );
	"tolerance has to be >= 0"
	assert ( tolerance >= 0 );
	
	Integer timers = delayList.size;
	variable Integer completedTimers = 0;
	variable Integer totalFires = 0;
	
	Anything(Integer) completing =
			( Integer numberOfFires ) {
				totalFires += numberOfFires;
				if ( ++ completedTimers == timers ) {
					context.complete( "total number of fires is ``totalFires``" );
				}
			};
	
	variable Integer index = 1;
	for ( delays in delayList ) {
		setupTimer( context, completing, scheduler, index ++, delays, tolerance );
	}
	
}


"setups a one timer"
void setupTimer (
	"context to report failures"
	AsyncTestContext context,
	"notifies that timer is completed, context is not used since several timers can be scheduled"
	void complete( Integer numberOfFires ),
	"scheduler to schedule a timer"
	Scheduler scheduler,
	"index of this timer"
	Integer timerIndex,
	"timer delays"
	{Integer*} delays,
	"tolerance to compare actual times with expected ones"
	Integer tolerance
) {
	Iterator<Integer> expected = delays.iterator();
	Integer startTime = system.milliseconds;
	variable Integer totalTime = 0;
	variable Integer fireTime = system.milliseconds;
	variable Integer delayIndex = 0;
	context.start();
	scheduler.schedule (
		delays.iterator(),
		() {
			// timer fires - compare delays with expected
			if ( is Integer exp = expected.next() ) {
				Integer actualDelay = system.milliseconds - fireTime;
				context.assertTrue (
					( actualDelay - exp ).magnitude <= tolerance,
					"expected delay of ``exp``ms is far away from actual ``actualDelay``ms with tolerance of ``tolerance``ms",
					"timer ``timerIndex``, fire ``delayIndex``"
				);
				totalTime += exp;
			}
			else {
				// error - timer to be exhausted
				context.fail( Exception( "timer fires but it doesn't have values to fire" ), "timer ``timerIndex``" );
			}
			fireTime = system.milliseconds;
			delayIndex ++;
		},
		() {
			// check if timer is exhausted
			if ( is Integer exp = expected.next() ) {
				// error - timer is not exhausted
				context.fail( Exception( "timer is completed but it still has values to fire" ), "timer ``timerIndex``" );
			}
			// check if total timer working time is close to expected one (sum of delays) 
			Integer actualTotal = system.milliseconds - startTime;
			context.assertTrue (
				( totalTime - actualTotal ).magnitude <= tolerance,
				"expected total time of ``totalTime``ms is far away from actual ``actualTotal``ms with tolerance of ``tolerance``ms",
				"timer ``timerIndex``"
			);
			// complete testing
			complete( delayIndex );
		},
		( Throwable err ) {
			// timer failing
			context.fail( err, "timer ``timerIndex``" );
			complete( delayIndex );
		}
	);
}
