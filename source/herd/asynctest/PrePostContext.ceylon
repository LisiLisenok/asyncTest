import java.util.concurrent.atomic {
	AtomicBoolean
}
import java.util.concurrent.locks {
	ReentrantLock,
	Condition
}
import ceylon.test {

	TestState
}
import ceylon.collection {

	ArrayList
}
import herd.asynctest.internal {

	ExecutionThread
}
import java.util.concurrent {

	CountDownLatch,
	TimeUnit { milliseconds }
}
import java.lang {

	ThreadGroup
}
import ceylon.language.meta.model {

	IncompatibleTypeException,
	InvocationException
}


"Performs initialization or disposing."
since( "0.6.0" )
by( "Lis" )
class PrePostContext()
{
	"Group to run functions if timeout specified."
	ThreadGroup group = ThreadGroup( "asyncpreposttester" );
	
	"locks concurrent access"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();

	
	"`false` if initialization completed"
	AtomicBoolean running = AtomicBoolean( true );
	
	"non-null if aborted"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	"Provides prepost context to clients."
	class InternalContext (	
			"Title for the currently run function."
			String currentFunction
	) satisfies AsyncPrePostContext {
		AtomicBoolean running = AtomicBoolean( true );
		
		shared void stop() { running.set( false ); }
		
		shared actual void abort( Throwable reason, String title ) {
			if ( running.compareAndSet( true, false ) ) {
				outer.abort (
					reason,
					if ( currentFunction.empty ) then title else
						if ( title.empty ) then currentFunction else currentFunction + ": " + title
				);
			}
		}
		
		shared actual void proceed() {
			if ( running.compareAndSet( true, false ) ) {
				outer.proceed();
			}
		}
		
		
	}
	
	void abort( Throwable reason, String title = "" ) {
		if ( running.compareAndSet( true, false ) ) {
			outputs.add( TestOutput( TestState.aborted, reason, 0, title ) );
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	void proceed() {
		if ( running.compareAndSet( true, false ) ) {
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	
	void runFunction( PrePostFunction init, InternalContext context ) {
		try { init.run( context ); }
		catch ( Throwable err ) {
			if ( is IncompatibleTypeException | InvocationException err ) {
				abort( err, "incompatible invocation of ``init.functionTitle``" );
			}
			else {
				abort( err );
			}
		}
		if ( running.get() ) { condition.await(); }
	}
	
	void runWithTimeout( PrePostFunction init ) {
		CountDownLatch latch = CountDownLatch( 1 );
		InternalContext context = InternalContext( init.functionTitle );
		ExecutionThread thr = ExecutionThread (
			group, "asyncpreposttester",
			() {
				try { 
					runFunction( init, context );
					if ( running.get() ) { condition.await(); }
				}
				catch ( Throwable err ) {}
				finally {
					context.stop();
					latch.countDown();
				}
			}
		);
		thr.start();
		if ( !latch.await( init.timeOutMilliseconds, milliseconds ) ) {
			context.stop();
			try { group.interrupt(); }
			catch ( Throwable err ) {}
			value excep = TimeOutException( init.timeOutMilliseconds );
			abort( excep, excep.message );
		}
	}
	
	"Runs initialization process. Returns errors if occured."
	shared TestOutput[] run( PrePostFunction[] inits ) {
		locker.lock();
		try {
			outputs.clear();
			for ( init in inits ) {
				running.set( true );
				if ( init.timeOutMilliseconds > 0 ) {
					runWithTimeout( init );
				}
				else {
					InternalContext context = InternalContext( init.functionTitle );
					runFunction( init, context );
					context.stop();
				}
			}
			return outputs.sequence();
		}
		finally {
			outputs.clear();
			running.set( false );
			locker.unlock();
		}
	}
	
	
	shared actual String string {
		String compl = if ( running.get() ) then "running" else "completed";
		return "TestInitContext, status: '``compl``'";
	}
	
}




