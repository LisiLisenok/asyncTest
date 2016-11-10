import herd.asynctest {
	AsyncPrePostContext
}
import java.util.concurrent.atomic {
	AtomicLong
}


"Atomically counts something. Resets to `initial` value before _each_ test."
since( "0.6.0" ) by( "Lis" )
shared class CounterRule( "Initial value of the counter." Integer initial = 0 ) satisfies TestRule {
	
	variable AtomicLong atomicCounter = AtomicLong( initial );
	
	
	"The current value of the counter."
	shared Integer counter => atomicCounter.get();
	
	"Adds delta to the current value and returns the result."
	shared Integer addAndGet( Integer delta = 1 ) => atomicCounter.addAndGet( delta );
	"Adds delta to the current value and returns the previous value."
	shared Integer getAndAdd( Integer delta = 1 ) => atomicCounter.getAndAdd( delta );
	"Decrements the value and returns the result."
	shared Integer decrementAndGet() => atomicCounter.decrementAndGet();
	"Increments the value and returns the result."
	shared Integer incrementAndGet() => atomicCounter.incrementAndGet();
	"Decrements the value and returns the previous value."
	shared Integer getAndDecrement() => atomicCounter.andDecrement;
	"Increments the value and returns the previous value."
	shared Integer getAndIncrement() => atomicCounter.andIncrement;
	
	
	shared actual void after( AsyncPrePostContext context ) => context.proceed();
	
	shared actual void before( AsyncPrePostContext context ) {
		atomicCounter = AtomicLong( initial );
		context.proceed();
	}
	
}
