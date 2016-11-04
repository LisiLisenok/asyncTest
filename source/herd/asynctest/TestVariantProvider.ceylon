

"Provides iterator for test variants.  
 Test execution context looks for annotations of test function which support the interface
 and performs testing according to provided variants."
see( `function parameterized` )
since( "0.6.0" ) by( "Lis" )
shared interface TestVariantProvider {
	"Iterator of the test variants.  
	 Not stream! Just iterator which helps to provide next variant base on results of previous."
	shared formal Iterator<TestVariant> variantsIterator();
}


"Combines several test variant iterators."
since( "0.6.0" ) by( "Lis" )
class CombinedVariantProvider( Iterator<Iterator<TestVariant>> providers ) satisfies Iterator<TestVariant> {
	
	variable Iterator<TestVariant>|Finished current = providers.next();
	
	
	shared actual TestVariant|Finished next() {
		while ( is Iterator<TestVariant> cur = current ) {
			if ( is TestVariant tv = cur.next() ) {
				return tv;
			}
			else {
				current = providers.next();
			}
		}
		return finished;
	}
	
}
