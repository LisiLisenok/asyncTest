import ceylon.collection {
	ArrayList
}
import ceylon.language.meta.model {
	IncompatibleTypeException,
	InvocationException,
	Type
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

	Matcher,
	MatchResult
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import ceylon.promise {

	Promise,
	Deferred
}


"Performs a one test execution."
since( "0.0.1" )
by( "Lis" )
class Tester() satisfies AsyncTestContext
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
	
	"Fills matcher with value, reports and returns results."
	void fillMatcher<Value> (
		Deferred<MatchResult> deferred, Value val, Matcher<Value> matcher, String title, Boolean reportSuccess
	) {
		try {
			value m = matcher.match( val );
			if ( m.accepted ) {
				if ( reportSuccess ) {
					addOutput (
						TestState.success,
						null,
						if ( title.empty ) then m.string else title + " - " + m.string
					);
				}
			}
			else {
				addOutput (
					TestState.failure, AssertionError( m.string ),
					if ( title.empty ) then m.string else title + " - " + m.string
				);
			}
			deferred.fulfill( m );
		}
		catch ( Throwable err ) {
			addOutput( TestState.failure, err, title );
			deferred.reject( err );
		}
	}
	
	"Aborts if matcher is rejected, reports and returns results."
	void abortIfNotMatched<Value>( Deferred<MatchResult> deferred, Value val, Matcher<Value> matcher, String title ) {
		try {
			value m = matcher.match( val );
			if ( !m.accepted ) {
				addOutput( TestState.aborted, AssertionError( m.string ), title );
			}
			deferred.fulfill( m );
		}
		catch ( Throwable err ) {
			addOutput( TestState.aborted, err, title );
			deferred.reject( err );
		}
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


	shared actual void succeed( String message ) {
		if ( running.get() ) {
			addOutput( TestState.success, null, message );
		}
	}

	shared actual Promise<MatchResult> assertThat<Value> (
		Value | Promise<Value> val, Matcher<Value> matcher, String title, Boolean reportSuccess
	) {
		Deferred<MatchResult> ret = Deferred<MatchResult>();
		if ( is Promise<Value> val ) {
			val.completed (
				( Value val ) {
					fillMatcher( ret, val, matcher, title, reportSuccess );
				},
				( Throwable err ) {
					addOutput( TestState.failure, err, title );
					ret.reject( err );
				}
			);
		}
		else {
			fillMatcher( ret, val, matcher, title, reportSuccess );
		}
		return ret.promise;
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
		if ( running.get() ) {
			addOutput( TestState.aborted, reason, title );
		}
	}
		
	shared actual Promise<MatchResult> assumeThat<Value> (
		Value | Promise<Value> val, Matcher<Value> matcher, String title
	) {
		Deferred<MatchResult> ret = Deferred<MatchResult>();  
		if ( is Promise<Value> val ) {
			val.completed (
				( Value val ) {
					abortIfNotMatched( ret, val, matcher, title );
				},
				( Throwable err ) {
					abort( err, title );
					ret.reject( err );
				}
			);
		}
		else {
			abortIfNotMatched( ret, val, matcher, title );
		}
		return ret.promise;
	}
	
	
	"Returns output from the test."
	shared TestOutput[] run( FunctionDeclaration functionDeclaration, Object? instance,
		Type<Anything>[] typeParameters, Anything* args
	) {
		if ( running.compareAndSet( false, true ) ) {
			locker.lock();
			try {
				// invoke test function
				if ( functionDeclaration.toplevel ) {
					functionDeclaration.invoke( typeParameters, this, *args );
				}
				else if ( exists i = instance ) {
					functionDeclaration.memberInvoke( i, typeParameters, this, *args );
				}
				else {
					abort (
						AssertionError (
							"Unable to instantiate container object of test function ``functionDeclaration``."
						)
					);
					complete();
				}
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
