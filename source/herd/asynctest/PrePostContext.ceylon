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

	ExecutionThread,
	LatchWaiter
}
import java.lang {

	ThreadGroup,
	Thread,
	ThreadDeath
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
	object group extends ThreadGroup( "asyncPrePost" ) {
		variable AsyncPrePostContext? context = null;
		
		shared void setContext( AsyncPrePostContext c ) {
			context = c;
		}
		
		shared void resetContext() {
			context = null;
		}
		
		shared actual void uncaughtException( Thread t, Throwable e ) {
			if ( is ThreadDeath e ) {
				super.uncaughtException( t, e );
			}
			else {
				if ( exists c = context ) {
					c.abort( e, "uncaught exception in child thread." );
					resetContext();
				}
				else {
					super.uncaughtException( t, e );
				}
			}
		}
	}
	
	"locks concurrent access"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();

	
	"`false` if initialization completed"
	AtomicBoolean running = AtomicBoolean( true );
	
	"non-null if aborted"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	"Provides prepost context to clients.  
	 Delegates reporting to `outer` until `stop` called."
	class InternalContext (	
			"Title for the currently run function." String currentFunction,
			shared actual TestInfo testInfo
	) satisfies AsyncPrePostContext {
		AtomicBoolean running = AtomicBoolean( true );
		
		"Stops context. No reporting will be submited to `outer`."
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
	
	
	"Aborts the test initialization or disposing."
	void abort( Throwable reason, String title = "" ) {
		if ( running.compareAndSet( true, false ) ) {
			outputs.add( TestOutput( TestState.aborted, reason, 0, title ) );
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	"Initialization or disposing has been completed - proceed next step."
	void proceed() {
		if ( running.compareAndSet( true, false ) ) {
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}
	
	
	"Runs prepost function."
	void runFunction( PrePostFunction init, InternalContext context ) {
		try { init.run( context ); }
		catch ( Throwable err ) {
			if ( is IncompatibleTypeException | InvocationException err ) {
				context.abort( err, "incompatible invocation of ``init.functionTitle``" );
			}
			else {
				context.abort( err );
			}
		}
		if ( running.get() ) {
			locker.lock();
			try { condition.await(); }
			finally { locker.unlock(); }
		}
	}
	
	"Runs prepost function in separated thread and controls timeout."
	void runInSeparatedThread( PrePostFunction init, TestInfo testInfo ) {
		LatchWaiter latch = LatchWaiter( 1 );
		InternalContext context = InternalContext( init.functionTitle, testInfo );
		group.setContext( context );
		ExecutionThread thr = ExecutionThread (
			group, "asyncPrePostThread",
			() {
				try { runFunction( init, context ); }
				catch ( Throwable err ) { context.abort( err ); }
				finally {
					context.stop();
					latch.countDown();
				}
			}
		);
		thr.start();
		if ( !latch.awaitUntil( init.timeOutMilliseconds ) ) {
			// timeout!
			context.stop();
			try { group.interrupt(); }
			catch ( Throwable err ) {}
			value excep = TimeOutException( init.timeOutMilliseconds );
			abort( excep, excep.message );
		}
		group.resetContext();
	}
	
	"Runs prepost process. Returns errors if occured."
	shared TestOutput[] run (
		"Function to be preposted" PrePostFunction[] inits,
		"Info about current test or `null` if prepost is global." TestInfo? testInfo 
	) {
		for ( init in inits ) {
			running.set( true );
			TestInfo t = testInfo else
				TestInfo( init.prepostDeclaration, [], init.arguments, init.functionTitle, init.timeOutMilliseconds );
			runInSeparatedThread( init, t );
		}
		running.set( false );
		value ret = outputs.sequence(); 
		outputs.clear();
		return ret;
	}
	
}
