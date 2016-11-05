import ceylon.test {
	TestState
}


"Enumerates test variants."
see( `interface TestVariantProvider` )
since( "0.6.0" ) by( "Lis" )
shared interface TestVariantEnumerator {
	"Currently applied test variant."
	shared formal TestVariant|Finished current;
	
	"Move to the next test variant. Sets `current` to the next variant to be tested."
	shared formal void moveNext (
		"Results of the test with `current` variant." TestVariantResult result
	);
}


"Provides a one empty test variant."
since( "0.6.0" ) by( "Lis" )
class EmptyTestVariantEnumerator() satisfies TestVariantEnumerator {
	variable TestVariant|Finished currentVal = emptyTestVariant;
	shared actual TestVariant|Finished current => currentVal;
	shared actual void moveNext(TestVariantResult result) => currentVal = finished;
}


"Iterates variants by arguments list and completes when number of failures reach limit."
see( `function parameterized` )
since( "0.6.0" ) by( "Lis" )
class TestVariantIterator (
	"Test variants iterator - function which returns next." TestVariant|Finished argsIterator(),
	"Limit on failures. When it is reached `next` returns `finished`." Integer maxFailedVariants
)
	satisfies TestVariantEnumerator
{
	variable Integer variantsFailed = 0;
	
	variable TestVariant|Finished curVariant = argsIterator();
	
	
	shared actual TestVariant|Finished current => curVariant;
	
	shared actual void moveNext( TestVariantResult result ) {
		if ( result.overallState > TestState.success ) {
			variantsFailed ++;
		}
		if ( maxFailedVariants < 1 || maxFailedVariants > variantsFailed ) {
			curVariant = argsIterator();
		}
		else {
			curVariant = finished;
		}
	}
	
}


"Combines several test variant iterators."
since( "0.6.0" ) by( "Lis" )
class CombinedVariantEnumerator( Iterator<TestVariantEnumerator> providers )
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

