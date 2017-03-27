import herd.asynctest {
	AsyncTestContext,
	AsyncPrePostContext
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
tagged( "Statement", "TestRule" ) since ( "0.6.0" ) by( "Lis" )
shared class GaugeStatement<Element>( Matcher<Element> matcher ) satisfies TestStatement & TestRule
{
	
	"Only current test has access."
	class Box() {
		"Provides synchronized access to `errors`."
		shared ReentrantLock locker = ReentrantLock();
		"Errors from matcher during the current execution."
		shared ArrayList<Throwable> errors = ArrayList<Throwable>();
	}
	
	CurrentTestStore<Box> stored = CurrentTestStore<Box>( Box );
	

	"Verifies `element` against the given `matcher`.  Thread-safe."
	shared void gauge( Element|Element() element ) {
		Box box = stored.element;
		box.locker.lock();
		try {
			MatchResult res = matcher.match( if ( is Element() element ) then element() else element );
			if ( !res.accepted ) {
				box.errors.add( AssertionError( res.string ) );
			}
		}
		catch ( Throwable err ) {
			box.errors.add( err );
		}
		finally { box.locker.unlock(); }
	}
	
	
	shared actual void apply( AsyncTestContext context ) {
		Box box = stored.element;
		box.locker.lock();
		try {
			for ( item in box.errors ) {
				context.fail( item );
			}
		}
		finally {
			box.errors.clear();
			box.locker.unlock();
			context.complete();
		}
	}
	
	
	shared actual void after( AsyncPrePostContext context ) => stored.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => stored.before( context );
	
}
