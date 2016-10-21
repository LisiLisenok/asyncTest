import herd.asynctest {

	AsyncTestContext,
	TestInitContext,
	AsyncTestExecutor,
	TestSuite,
	sequential,
	parameterized
}
import ceylon.test {

	test,
	testExecutor
}
import herd.asynctest.match {

	CloseTo,
	PassType,
	IsType
}


shared {[[], [{{Integer*}*}, Integer]]*} oneConstantTimer
		=> {[[], [{{250}.repeat( 7 )}, 50]]};
shared {[[], [{{Integer*}*}, Integer]]*} oneDoubleTimer
		=> {[[], [{{250, 350}.repeat( 5 )}, 50]]};
shared {[[], [{{Integer*}*}, Integer]]*} oneTripleTimer
		=> {[[], [{{250, 450, 200}.repeat( 4 )}, 50]]};
shared {[[], [{{Integer*}*}, Integer]]*} oneIncreasingTimer
		=> {[[], [{{250, 400, 450, 600, 820, 900}}, 50]]};
shared {[[], [{{Integer*}*}, Integer]]*} twoConstantTimers
		=> {[[], [{{250}.repeat( 7 ), {350}.repeat( 6 )}, 50]]};
shared {[[], [{{Integer*}*}, Integer]]*} twoDoubleTimers
		=> {[[], [{{250, 350}.repeat( 7 ), {350, 280}.repeat( 6 )}, 50]]};
shared {[[], [{{Integer*}*}, Integer]]*} threeConstantTimers
		=> {[[], [{{250}.repeat( 7 ), {350}.repeat( 6 ), {300}.repeat( 5 )}, 50]]};
shared {[[], [{{Integer*}*}, Integer]]*} threeDoubleTimers
		=> {[[], [{{250, 350}.repeat( 7 ), {400, 350}.repeat( 4 ), {350, 280}.repeat( 6 )}, 50]]};

"Scheduler test parameters."
shared {[[], [{{Integer*}*}, Integer]]*} combinedTimers
		=> oneConstantTimer.chain( oneDoubleTimer ).chain( oneTripleTimer ).chain( oneIncreasingTimer )
			.chain( twoConstantTimers ).chain( twoDoubleTimers ).chain( threeConstantTimers ).chain( threeDoubleTimers );


"Performs scheduler test.
 
 ####Annotations:
 * `test` - asks Ceylon test tool to run this function
 * `testExecutor` - asks to run this test using executor provided by the annotation argument
 * `parameter` - asks to perform test using parameters provided by the annotation argument
 
 
 ####Test procedure:
 
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
sequential class SchedulerTester() satisfies TestSuite {
	
	// instantiate scheduler
	Scheduler scheduler = Scheduler( 2 );
	
	
	test
	testExecutor( `class AsyncTestExecutor` )
	parameterized( `value combinedTimers` )
	shared void scheduleFires (
		"Context the test is performed on." AsyncTestContext context,
		"List of delays submited to [[Scheduler.schedule]]." {{Integer*}*} delayList,
		"Tolerance used to compare actual and expected delays, to be >= 0." Integer tolerance
	) {
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
			setupTimer( context, completing, index ++, delays, tolerance );
		}
	}


	"setups a one timer"
	void setupTimer (
		"context to report failures"
		AsyncTestContext context,
		"notifies that timer is completed, context is not used since several timers can be scheduled"
		void complete( Integer numberOfFires ),
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
		scheduler.schedule (
			delays.iterator(),
			() {
				// check if actual timer delay is close to expected one
				Integer actualDelay = system.milliseconds - fireTime;
				context.assertThat (
					expected.next(),
					PassType<Integer>( CloseTo( actualDelay, tolerance ) ),
					"timer ``timerIndex``, fire ``delayIndex``"
				);
				totalTime += actualDelay;
				fireTime = system.milliseconds;
				delayIndex ++;
			},
			() {
				// check if timer is exhausted
				context.assertThat (
					expected.next(),
					IsType<Finished>(),
					"timer ``timerIndex``"
				);
				// check if total timer working time is close to expected one (sum of delays) 
				Integer actualTotal = system.milliseconds - startTime;
				context.assertThat (
					totalTime,
					CloseTo( actualTotal, tolerance ),
					"timer ``timerIndex``",
					true
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
	
	shared actual void dispose( AsyncTestContext context ) {
		scheduler.stopAll();
		context.complete();
	}
	
	shared actual void initialize( TestInitContext initContext ) => initContext.proceed();
	
}
