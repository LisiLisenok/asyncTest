import ceylon.collection {
	ArrayList
}
import ceylon.language.meta.model {
	IncompatibleTypeException,
	InvocationException
}
import ceylon.test {
	TestState
}
import ceylon.test.engine {
	TestAbortedException,
	TestSkippedException
}

import java.util.concurrent.atomic {
	AtomicBoolean
}
import java.util.concurrent.locks {
	ReentrantLock,
	Condition
}
import herd.asynctest.match {

	Matcher
}


"Performs a one test execution."
by( "Lis" )
class Tester( InitStorage inits ) satisfies AsyncTestContext
{
	
	"`true` if currently run"
	AtomicBoolean running = AtomicBoolean( false );
	"locker behind this running"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();


	"outputs locking"
	ReentrantLock outputLocker = ReentrantLock();
	"storage for reports"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	
	variable Integer startTime = 0;
	variable Integer completeTime = 0; 
	
	"total running interval, milliseconds"
	shared Integer runInterval => if ( completeTime > startTime ) then completeTime - startTime else 0;
	
	
	"adds new output to `outputs`"
	void addOutput(	TestState state, Throwable? error, String title ) {
		Integer elapsed = if ( startTime > 0 ) then system.milliseconds - startTime else 0;
		outputLocker.lock();
		try { outputs.add( TestOutput( state, error, elapsed, title ) ); }
		finally { outputLocker.unlock(); }
	}
	
	
	shared actual void start() {
		if ( running.get() ) {
			startTime = system.milliseconds;
			completeTime = startTime;
		}
	}
	
	shared actual void complete( String title ) {
		if ( running.compareAndSet( true, false ) ) {
			if ( outputs.empty && !title.empty ) { addOutput( TestState.success, null, title ); }
			completeTime = system.milliseconds;
			if ( startTime == 0 ) { startTime = completeTime; }
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}


	shared actual Item? get<Item>( String name ) => inits.retrieve<Item>( name );
	
	shared actual Item[] getAll<Item>() => inits.retrieveAll<Item>();

	
	shared actual void succeed( String message ) {
		if ( running.get() ) {
			addOutput( TestState.success, null, message );
		}
	}
	
	shared actual void assertTrue( Boolean condition, String message, String title, String? successMessage ) {
		if ( running.get() ) {
			if ( !condition ) {
				addOutput( TestState.failure, AssertionError( message ), title );
			}
			else if ( exists str = successMessage ) {
				succeed( str );
			}
		}
	}
	
	shared actual void assertFalse( Boolean condition, String message, String title, String? successMessage ) {
		if ( running.get() ) {
			if ( condition ) {
				addOutput( TestState.failure, AssertionError( message ), title );
			}
			else if ( exists str = successMessage ) {
				succeed( str );
			}
		}
	}
	
	shared actual void assertNull( Anything val, String message, String title, String? successMessage ) {
		if ( running.get() ) {
			if ( val exists ) {
				addOutput( TestState.failure, AssertionError( message ), title );
			}
			else if ( exists str = successMessage ) {
				succeed( str );
			}
		}
	}
	
	shared actual void assertNotNull( Anything val, String message, String title, String? successMessage ) {
		if ( running.get() ) {
			if ( !val exists ) {
				addOutput( TestState.failure, AssertionError( message ), title );
			}
			else if ( exists str = successMessage ) {
				succeed( str );
			}
		}
	}

	shared actual void assertThat<Value>( Value val, Matcher<Value> matcher, String title ) {
		value m = matcher.match( val );
		if ( m.accepted ) {
			addOutput( TestState.success, null, title + " - " + m.string );
		}
		else {
			addOutput( TestState.failure, AssertionError( m.string ), title );
		}
	}

	
	shared actual void fail( Throwable reason, String title ) {
		if ( running.get() ) {
			if ( is AssertionError reason ) {
				addOutput( TestState.failure, reason, title );
			}
			else {
				addOutput( TestState.error, reason, title );
			}
		}
	}
	
	shared actual void abort( Throwable? reason, String title ) {
		if ( running.get() ) { addOutput( TestState.aborted, reason, title ); }
	}
		
	shared actual void assumeThat<Value>( Value val, Matcher<Value> matcher, String title ) {
		value m = matcher.match( val );
		if ( !m.accepted ) {
			addOutput( TestState.aborted, AssertionError( m.string ), title );
		}
	}
	
	
	"Returns output from the test"
	shared TestOutput[] run( Anything(AsyncTestContext) tested ) {
		if ( running.compareAndSet( false, true ) ) {
			locker.lock();
			try {
				tested( this );
				if ( running.get() ) { condition.await(); }
			}
			catch ( Throwable err ) {
				if ( err is TestSkippedException ) {
					addOutput( TestState.skipped, err, "skipped with exception" );
				}
				else if ( err is TestAbortedException ) {
					abort( err, "aborted with exception" );
				}
				else if  ( err is IncompatibleTypeException | InvocationException ) {
					abort( err, "incompatible invocation" );
				}
				else {
					fail( err, "failed with exception" );
				}
				complete();
			}
			finally {
				locker.unlock();
			}
			
			outputLocker.lock();
			try {
				value ret = outputs.sequence();
				outputs.clear();
				return ret;
			}
			finally { outputLocker.unlock(); }
		}
		else {
			return [];
		}
	}	
	
	
	shared actual String string {
		String compl = if ( running.get() ) then "running" else "completed";
		return "AsyncTestContext, status: '``compl``', current number of reports = ``outputs.size``, running time = ``runInterval``";
	}
	
}
