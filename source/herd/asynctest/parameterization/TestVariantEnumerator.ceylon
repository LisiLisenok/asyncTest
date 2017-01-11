import ceylon.test {
	TestState
}


"Enumerates test variants."
tagged( "Base" )
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


"Iterates variants by arguments list and completes when number of failures reach limit."
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


"Delegates enumeration to another enumerator but completes when number of failures reach limit."
since( "0.7.0" ) by( "Lis" )
class TestVariantMaxFailureEnumerator (
	"Test variants iterator - function which returns next." TestVariantEnumerator other,
	"Limit on failures. When it is reached `next` returns `finished`." Integer maxFailedVariants
)
		satisfies TestVariantEnumerator
{
	variable Integer variantsFailed = 0;
	
	shared actual TestVariant|Finished current {
		if ( maxFailedVariants < 1 || maxFailedVariants > variantsFailed ) {
			return other.current;
		}
		else {
			return finished;
		}
	}
	
	shared actual void moveNext( TestVariantResult result ) {
		if ( result.overallState > TestState.success ) {
			variantsFailed ++;
		}
		if ( maxFailedVariants < 1 || maxFailedVariants > variantsFailed ) {
			other.moveNext( result );
		}
	}
	
}
