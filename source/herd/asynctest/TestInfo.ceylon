import ceylon.language.meta.declaration {
	FunctionDeclaration
}
import ceylon.language.meta.model {
	Type
}
import herd.asynctest.runner {
	AsyncTestRunner
}
import herd.asynctest.internal {
	sequenceHash
}


"Test info provided to prepost functions or test runners."
see( `interface AsyncPrePostContext`, `interface AsyncTestRunner` )
since( "0.6.0" ) by( "Lis" )
shared final class TestInfo (
	"Declaration of the test function."
	shared FunctionDeclaration testFunction,
	"Generic type parameters."
	shared Type<Anything>[] parameters,
	"Function arguments."
	shared Anything[] arguments,
	"Test variant name as represented in the test report."
	shared String variantName,
	"Time out in milliseconds for a one test function run, <= 0 if no limit."
	shared Integer timeOutMilliseconds
) {
	
	variable Integer memoizedHash = 0;
	
	shared actual Boolean equals( Object that ) {
		if ( is TestInfo that ) {
			return testFunction == that.testFunction && 
				parameters == that.parameters && 
				arguments == that.arguments && 
				variantName == that.variantName && 
				timeOutMilliseconds == that.timeOutMilliseconds;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash {
		if ( memoizedHash == 0 ) {
			memoizedHash = sequenceHash( parameters, 31 );
			memoizedHash = 31 * memoizedHash + sequenceHash( arguments, 31 );
			memoizedHash = 31 * memoizedHash + testFunction.hash;
			memoizedHash = 31 * memoizedHash + variantName.hash;
			memoizedHash = 31 * memoizedHash + timeOutMilliseconds;
		}
		return memoizedHash;
	}
	
}
