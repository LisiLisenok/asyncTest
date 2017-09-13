import java.lang {
	ThreadLocal
}
import java.util {
	Random
}


"Randomly chooses bench function argument from `sourceData` and pass selected argument to `benchFunction`.  
 The argument is selected independently for each execution thread.
 "
tagged( "Bench flow" )
since( "0.7.0" ) by( "Lis" )
shared class RandomDataFlow<in Argument> (
	"Bench function." Anything(Argument) benchFunction,
	"Source data for random selection and each execution." Argument[] sourceData
)
		satisfies BenchFlow<[]>
{
	
	ThreadLocal<Argument> currentData = ThreadLocal<Argument>();
	Random rnd = Random();
	
	
	shared actual default void after() {}
	
	shared actual default void before() {
		currentData.set( sourceData[rnd.nextInt( sourceData.size )] );
	}
	
	shared actual default Anything() bench {
		value data = currentData.get();
		return () => benchFunction( data );
	}
	
	shared actual default void dispose() {}
	
	shared actual default void setup() {}
	
}
