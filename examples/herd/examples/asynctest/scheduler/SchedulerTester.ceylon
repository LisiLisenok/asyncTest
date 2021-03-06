import herd.asynctest {
	AsyncTestContext,
	async,
	arguments,
	AsyncPrePostContext
}
import ceylon.test {

	test,
	afterTestRun
}
import herd.asynctest.match {

	CloseTo,
	PassType,
	IsType
}
import java.lang {

	Runtime
}
import herd.asynctest.parameterization {
	parameterized,
	TestVariant
}


shared {TestVariant*} testTimers => {
	TestVariant([], [{{250}.repeat( 7 )}, 50]),
	TestVariant([], [{{250, 350}.repeat( 5 )}, 50]),
	TestVariant([], [{{250, 450, 200}.repeat( 4 )}, 50]),
	TestVariant([], [{{250, 400, 450, 600, 820, 900}}, 50]),
	TestVariant([], [{{250}.repeat( 7 ), {350}.repeat( 6 )}, 50]),
	TestVariant([], [{{250, 350}.repeat( 7 ), {350, 280}.repeat( 6 )}, 50]),
	TestVariant([], [{{250}.repeat( 7 ), {350}.repeat( 6 ), {300}.repeat( 5 )}, 50]),
	TestVariant([], [{{250, 350}.repeat( 7 ), {400, 350}.repeat( 4 ), {350, 280}.repeat( 6 )}, 50])
};


"Returns number of available cores."
Integer[1] schedulerArgs() => [Runtime.runtime.availableProcessors()];


"Performs scheduler test.
 
 ####Annotations:
 * `test` - asks Ceylon test tool to run this function
 * `async` - asks to run this test using executor provided by the annotation argument
 * `parameterized` - asks to perform test using parameters provided by the annotation argument
 
 
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
arguments( `function schedulerArgs` )
class SchedulerTester( Integer corePoolSize ) {
	
	// instantiate scheduler
	Scheduler scheduler = Scheduler( corePoolSize );
	
	test async
	parameterized( `value testTimers` )
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
	
	afterTestRun shared void dispose( AsyncPrePostContext context ) {
		scheduler.stopAll();
		context.proceed();
	}
	
}
