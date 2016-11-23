import ceylon.language.meta.declaration {
	FunctionDeclaration
}


"Provides enumerator for test variants.  
 Test execution context looks for annotations of the test function which support the interface
 and performs testing according to provided variants.
 As example, see [[parameterized]].
 "
see( `class TestVariant` )
since( "0.6.0" ) by( "Lis" )
shared interface TestVariantProvider {
	"Returns enumerator on the test variants."
	shared formal TestVariantEnumerator variants (
		"Declaration of the function to be tested." FunctionDeclaration testFunction,
		"Instance of the test class or `null` if test is performed using top-level function." Object? instance
	);
}
