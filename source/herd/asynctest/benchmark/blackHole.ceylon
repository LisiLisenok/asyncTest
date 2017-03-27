import java.util.concurrent.atomic {
	AtomicLong
}


"Represents a black hole in order to eliminate JIT optimizations.  
 
 Usage:  
 * call [[clear]] before testing  
 * call [[consume]] when object has to be consumed to eliminate JIT optimizations
 * call [[verifyNumbers]] after the test in order to eliminate JIT optimizations on this `blackHole` object
 "
since( "0.7.0" ) by( "Lis" )
object blackHole {
	
	"Total number of non-null objects consumed by the black hole."
	shared AtomicLong totalObjects = AtomicLong( 0 );
	"Total number of nulls consumed by the black hole."
	shared AtomicLong totalNulls = AtomicLong( 0 );
	
	"Prevents JIT to eliminate dependent computations."
	shared void consume( Anything something ) {
		if ( something exists ) {
			totalObjects.incrementAndGet();
		}
		else {
			totalNulls.incrementAndGet();
		}
	}
	
	"Resets number of consumed objects to zero."
	shared void clear() {
		totalObjects.set( 0 );
		totalNulls.set( 0 );
	}
	
	
	"Verifies number of consumed objects in order to eliminate JIT optimizations on this `blackHole` object."
	shared void verifyNumbers() {
		"Total number of consumed objects may not be less than zero."
		assert ( totalObjects.get() + totalNulls.get() >= 0 );
	}
	
}


"Prevents JIT to eliminate dependent computations."
since( "0.7.0" ) by( "Lis" )
shared void pushToBlackHole( Anything something ) => blackHole.consume( something );
