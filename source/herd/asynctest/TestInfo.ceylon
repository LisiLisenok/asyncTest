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


"Information on currently running test variant."
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
	"Timeout in milliseconds for a one test function run, if <= 0 no limit."
	shared Integer timeoutMilliseconds
) {
	
	variable Integer memoizedHash = 0;
	
	shared actual Boolean equals( Object that ) {
		if ( is TestInfo that ) {
			return testFunction == that.testFunction && 
				parameters == that.parameters && 
				arguments == that.arguments && 
				variantName == that.variantName && 
				timeoutMilliseconds == that.timeoutMilliseconds;
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
			memoizedHash = 31 * memoizedHash + timeoutMilliseconds;
		}
		return memoizedHash;
	}
	
}
