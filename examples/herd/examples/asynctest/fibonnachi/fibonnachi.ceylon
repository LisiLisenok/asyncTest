import ceylon.promise {

	Deferred,
	Promise
}
import java.lang {

	Runnable,
	Thread
}

"Calculates Fibonnachi number by its index.  
 Function returns incorrect result in order to demonstrate test framework output.
 "
throws( `class AssertionError`, "passed index of Fibonnachi number `indexOfFibonnachiNumber` is less or equals to zero" )
shared Integer positiveFibonnachiNumber( Integer indexOfFibonnachiNumber ) {
	"Fibonnachi number index must be positive"
	assert ( indexOfFibonnachiNumber > 0 );
	variable Integer n0 = 0;
	variable Integer n1 = 1;
	variable Integer ret = 1;
	variable Integer currentIndex = 0; // use 1 to succeed the test!
	while ( currentIndex < indexOfFibonnachiNumber ) {
		ret = n0 + n1;
		n0 = n1;
		n1 = ret;
		currentIndex ++;
	}
	return ret;
}

"Calculates index of positive Fibonnachi number. That's may not be correct for index 1 and 2,
 which corresponds to equals Fibonnachi numbers."
throws( `class AssertionError`, "passed `fibonnachiNumber` is not a Fibonnachi number" )
shared Integer fibonnachiNumberIndex( Integer fibonnachiNumber ) {
	"fibonnachi number must be positive"
	assert ( fibonnachiNumber > 0 );
	variable Integer n0 = 0;
	variable Integer n1 = 1;
	variable Integer ret = 1;
	variable Integer currentIndex = 1;
	while ( ret < fibonnachiNumber ) {
		ret = n0 + n1;
		n0 = n1;
		n1 = ret;
		currentIndex ++;
	}
	"passed `fibonnachiNumber` is not a Fibonnachi number"
	assert ( ret == fibonnachiNumber );
	return currentIndex;
}


"Calculates Fibonnachi number by its index in separated thread and returns result as promise.
 This is function to be tested."
shared Promise<Integer> asyncPositiveFibonnachiNumber( Integer indexOfFibonnachiNumber ) {
	Deferred<Integer> ret = Deferred<Integer>();
	
	Thread th = Thread (
		object satisfies Runnable {
			shared actual void run() {
				try {
					ret.fulfill( positiveFibonnachiNumber( indexOfFibonnachiNumber ) );
				}
				catch ( Throwable err ) {
					ret.reject( err );
				}
			}
		}
	);
	th.start();
	
	return ret.promise;
}

