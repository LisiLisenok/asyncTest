import herd.asynctest.parameterization {
	TestVariant,
	TestVariantEnumerator
}



"Test variant without any arguments."
since( "0.6.0" ) by( "Lis" )
shared object emptyTestVariant extends TestVariant( [], [] ) {
	shared actual String variantName = "";
	shared actual Boolean equals( Object that ) {
		if ( is TestVariant that ) {
			return that === this;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash => 37;	
}


"Provides a one empty test variant."
since( "0.6.0" ) by( "Lis" )
shared class EmptyTestVariantEnumerator() satisfies TestVariantEnumerator {
	variable TestVariant|Finished currentVal = emptyTestVariant;
	shared actual TestVariant|Finished current => currentVal;
	shared actual void moveNext(TestVariantResult result) => currentVal = finished;
}


"Combines several test variant iterators."
since( "0.6.0" ) by( "Lis" )
shared class CombinedVariantEnumerator( Iterator<TestVariantEnumerator> providers )
		satisfies TestVariantEnumerator
{
	
	variable TestVariantEnumerator|Finished currentProvider = providers.next();
	
	TestVariant|Finished moveNextProvider() {
		while ( is TestVariantEnumerator cur = currentProvider ) {
			if ( is TestVariant tv = cur.current ) {
				return tv;
			}
			else {
				currentProvider = providers.next();
			}
		}
		return finished;
	}
	
	variable TestVariant|Finished currrentVariant = moveNextProvider();
	
	
	shared actual TestVariant|Finished current => currrentVariant;
	
	shared actual void moveNext( TestVariantResult result ) {
		if ( is TestVariantEnumerator cur = currentProvider ) {
			cur.moveNext( result );
			if ( is TestVariant tv = cur.current ) {
				currrentVariant = tv;
				return;
			}
		}
		currrentVariant = moveNextProvider();
	}	
	
}
