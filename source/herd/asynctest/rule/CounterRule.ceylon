import herd.asynctest {
	AsyncPrePostContext
}
import java.util.concurrent.atomic {
	AtomicLong
}


"Atomically counts something. Resets to `initial` value before _each_ test."
tagged( "TestRule" ) since( "0.6.0" ) by( "Lis" )
shared class CounterRule( "Initial value of the counter." Integer initial = 0 ) satisfies TestRule {
	
	AtomicLong initialAtomic() => AtomicLong( initial );
	CurrentTestStore<AtomicLong> atomicCounter = CurrentTestStore<AtomicLong>( initialAtomic );
	
	
	"The current value of the counter."
	shared Integer counter => atomicCounter.element.get();
	
	"Adds delta to the current value and returns the result."
	shared Integer addAndGet( Integer delta = 1 ) => atomicCounter.element.addAndGet( delta );
	"Adds delta to the current value and returns the previous value."
	shared Integer getAndAdd( Integer delta = 1 ) => atomicCounter.element.getAndAdd( delta );
	"Decrements the value and returns the result."
	shared Integer decrementAndGet() => atomicCounter.element.decrementAndGet();
	"Increments the value and returns the result."
	shared Integer incrementAndGet() => atomicCounter.element.incrementAndGet();
	"Decrements the value and returns the previous value."
	shared Integer getAndDecrement() => atomicCounter.element.andDecrement;
	"Increments the value and returns the previous value."
	shared Integer getAndIncrement() => atomicCounter.element.andIncrement;
	
	
	shared actual void after( AsyncPrePostContext context ) => atomicCounter.after( context );
	
	shared actual void before( AsyncPrePostContext context ) => atomicCounter.before( context );
	
}
