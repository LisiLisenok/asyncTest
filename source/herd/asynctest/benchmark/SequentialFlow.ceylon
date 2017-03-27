import java.lang {
	ThreadLocal
}
import java.util.\ifunction {
	Supplier
}


"Sequentially selects bench function from the given list independently for the each running thread."
tagged( "Bench flow" )
see( `class SingleBench`, `class MultiBench` )
since( "0.7.0" ) by( "Lis" )
shared class SequentialFlow<in Parameter> (
	shared actual Integer | Integer() iterations,
	"A list of bench functions to be sequentially selected." Anything(*Parameter)+ benchFunctions
)
		extends AbstractSelectiveFlow<Parameter>()
		given Parameter satisfies Anything[]
{
	
	ThreadLocal<Integer> current = ThreadLocal<Integer>.withInitial (
		object satisfies Supplier<Integer> {
			shared actual Integer get() => 0;
		}
	); 
	
	shared actual Anything(*Parameter) select() {
		Integer cur = current.get();
		if ( exists ret = benchFunctions[cur] ) {
			current.set( cur + 1 );
			return ret;
		}
		else {
			current.set( 1 );
			return benchFunctions.first;
		}
	}
	
}
