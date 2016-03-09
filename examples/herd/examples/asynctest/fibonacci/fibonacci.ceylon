import ceylon.promise {

	Deferred,
	Promise
}
import java.lang {

	Runnable,
	Thread
}

"Calculates Fibonacci number by its index.
 "
throws( `class AssertionError`, "passed index of Fibonacci number `indexOfFibonacciNumber` is less or equals to zero" )
shared Integer positiveFibonacciNumber( Integer indexOfFibonacciNumber ) {
	"Fibonnachi number index must be positive"
	assert ( indexOfFibonacciNumber > 0 );
	variable Integer n0 = 0;
	variable Integer n1 = 1;
	variable Integer ret = 1;
	variable Integer currentIndex = 1;
	while ( currentIndex < indexOfFibonacciNumber ) {
		ret = n0 + n1;
		n0 = n1;
		n1 = ret;
		currentIndex ++;
	}
	return ret;
}

"Calculates index of positive Fibonacci number. That's may not be correct for index 1 and 2,
 which corresponds to equals Fibonacci numbers."
throws( `class AssertionError`, "passed `fibonacciNumber` is not a Fibonacci number" )
shared Integer fibonacciNumberIndex( Integer fibonacciNumber ) {
	"fibonacci number must be positive"
	assert ( fibonacciNumber > 0 );
	variable Integer n0 = 0;
	variable Integer n1 = 1;
	variable Integer ret = 1;
	variable Integer currentIndex = 1;
	while ( ret < fibonacciNumber ) {
		ret = n0 + n1;
		n0 = n1;
		n1 = ret;
		currentIndex ++;
	}
	"passed `fibonacciNumber` is not a Fibonacci number"
	assert ( ret == fibonacciNumber );
	return currentIndex;
}


"Calculates Fibonacci number by its index in separated thread and returns result as promise.
 This is function to be tested."
shared Promise<Integer> asyncPositiveFibonacciNumber( Integer indexOfFibonacciNumber ) {
	Deferred<Integer> ret = Deferred<Integer>();
	
	Thread th = Thread (
		object satisfies Runnable {
			shared actual void run() {
				try {
					ret.fulfill( positiveFibonacciNumber( indexOfFibonacciNumber ) );
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

