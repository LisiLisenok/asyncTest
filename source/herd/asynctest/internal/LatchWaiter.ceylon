import java.util.concurrent {
	CountDownLatch,
	TimeUnit { milliseconds }
}


"CountDownLatch."
since( "0.6.0" ) by( "Lis" )
shared class LatchWaiter( Integer n ) extends CountDownLatch( n ) {
	
	"Await until `timeMilliseconds` or unlimited if it is <= 0.  
	 Returns `true` if completed by latch and `false` if by time."
	shared Boolean awaitUntil( Integer timeMilliseconds ) {
		if ( timeMilliseconds > 0 ) {
			return await( timeMilliseconds, milliseconds );
		}
		else {
			await();
			return true;
		}
	}
}
