import herd.asynctest {
	AsyncPrePostContext,
	TestInfo
}
import ceylon.collection {
	ArrayList
}
import ceylon.test.engine {
	MultipleFailureException
}
import java.util.concurrent.atomic {
	AtomicBoolean
}
import java.util.concurrent.locks {
	Condition,
	ReentrantLock
}


"Provides in chain calls of the given functions."
since( "0.6.0" ) by( "Lis" )
class ChainedPrePostContext( AsyncPrePostContext context, Iterator<Anything(AsyncPrePostContext)> functions )
{
	"Notify to run next function."
	ReentrantLock locker = ReentrantLock();
	Condition completed = locker.newCondition();
	
	"Collecting aborts."
	ArrayList<[Throwable, String]> abortReasons = ArrayList<[Throwable, String]>();
	
	"Boxing the context in order to admit only one report from each prepost function."
	class AsyncPrePostContextBox() satisfies AsyncPrePostContext {
		AtomicBoolean runningAtomic = AtomicBoolean( true );
		
		shared Boolean running => runningAtomic.get();
		
		shared actual void abort(Throwable reason, String title) {
			if ( runningAtomic.compareAndSet( true, false ) ) {
				abortReasons.add( [reason, title] );
				locker.lock();
				try { completed.signal(); }
				finally { locker.unlock(); }
			}
		}
		
		shared actual void proceed() {
			if ( runningAtomic.compareAndSet( true, false ) ) {
				locker.lock();
				try { completed.signal(); }
				finally { locker.unlock(); }
			}
		}
		
		shared actual TestInfo testInfo => context.testInfo;
	}
	
	
	void processPrepost() {
		while ( is Anything(AsyncPrePostContext) f = functions.next() ) {
			// execute next chained function
			value box = AsyncPrePostContextBox();
			try { f( box ); }
			catch ( Throwable err ) {
				abortReasons.add( [err, ""] );
			}
			if ( box.running ) {
				// await completion
				if ( locker.tryLock() ) {
					try { completed.await(); }
					finally { locker.unlock(); }
				}
			}
		}
	}
	
	shared void start() {
		processPrepost();
		if ( abortReasons.empty ) {
			// no errors occured - complete the chain
			context.proceed();
		}
		else if ( abortReasons.size == 1, exists first = abortReasons.first ) {
			context.abort( first[0], first[1] );
		}
		else {
			String title = "multiple abort reasons (``abortReasons.size``)";
			context.abort( MultipleFailureException( [for ( r in abortReasons ) r[0]], title ), title );
		}		
	}
	
}
