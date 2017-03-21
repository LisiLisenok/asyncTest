import java.lang {
	ThreadLocal
}
import java.util.\ifunction {
	Supplier
}


"Abstract base class for flow which selects another bench function each given number of benchmark iterations.  
 Bench functions are selected independently for each execution thread."
tagged( "Bench flow" )
since( "0.7.0" ) by( "Lis" )
shared abstract class AbstractSelectiveFlow<in Parameter> (
)
		satisfies BenchFlow<Parameter>
		given Parameter satisfies Anything[]
{
	
	ThreadLocal<Integer> localIterations = ThreadLocal<Integer>.withInitial (
		object satisfies Supplier<Integer> {
			shared actual Integer get() => 0;
		}
	); 
	ThreadLocal<Integer> numOfIterations = ThreadLocal<Integer>.withInitial (
		object satisfies Supplier<Integer> {
			shared actual Integer get() => 0;
		}
	);
	ThreadLocal<Anything(*Parameter)> currentBench = ThreadLocal<Anything(*Parameter)>();
	
	void setNumOfIterations() {
		value it = iterations;
		if ( is Integer it ) {
			numOfIterations.set( it );
		}
		else {
			numOfIterations.set( it() );
		}
	}

	
	"Selects another bench function each time when called."
	shared formal Anything(*Parameter) select();
	
	"Source of a number of iterations after which bench function has to be reselected.  
	 Might be variable.  
	 If <= 0 bench function is reselected at each iteration."
	shared formal Integer | Integer() iterations;

	
	shared actual Anything(*Parameter) bench => currentBench.get();
	
	shared actual default void setup() {
		currentBench.set( select() );
		setNumOfIterations();
	}
	shared actual default void before() {}
	shared actual default void after() {
		Integer current = localIterations.get();
		if ( current >= numOfIterations.get() ) {
			setNumOfIterations();
			currentBench.set( select() );
			localIterations.set( 0 );
		}
		else {
			localIterations.set( current + 1 );
		}
	}
	shared actual default void dispose() {}
	
}
