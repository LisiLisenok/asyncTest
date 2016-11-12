import herd.asynctest {
	AsyncTestContext
}
import herd.asynctest.match {
	Matcher,
	MatchResult
}
import java.util.concurrent.locks {
	ReentrantLock
}
import ceylon.collection {
	ArrayList
}


"Statement which verifies an element against given `matcher` each time when gauged,
 i.e. when [[gauge]] method is called.  
 If matcher rejects verification the fail report is added to the final test report."
see( `function AsyncTestContext.assertThat`, `package herd.asynctest.match` )
tagged( "Statement" ) since ( "0.6.0" ) by( "Lis" )
shared class GaugeStatement<Element>( Matcher<Element> matcher ) satisfies TestStatement
{
	"Provides synchronized access to `errors`."
	ReentrantLock locker = ReentrantLock();
	"Errors from matcher during the current execution."
	ArrayList<Throwable> errors = ArrayList<Throwable>();
	

	"Verifies `element` against the given `matcher`.  Thread-safe."
	shared void gauge( Element|Element() element ) {
		locker.lock();
		try {
			MatchResult res = matcher.match( if ( is Element() element ) then element() else element );
			if ( !res.accepted ) {
				errors.add( AssertionError( res.string ) );
			}
		}
		catch ( Throwable err ) {
			errors.add( err );
		}
		finally { locker.unlock(); }
	}
	
	
	shared actual void apply( AsyncTestContext context ) {
		locker.lock();
		try {
			for ( item in errors ) {
				context.fail( item );
			}
			errors.clear();
		}
		finally {
			locker.unlock();
			context.complete();
		}
	}
	
}
