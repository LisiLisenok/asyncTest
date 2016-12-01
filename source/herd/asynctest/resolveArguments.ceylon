import ceylon.language.meta.declaration {

	FunctionDeclaration,
	ClassDeclaration
}
import ceylon.language.meta {

	optionalAnnotation
}


"Resolves a list of type parameters and function arguments provided by [[parameterized]] annotation.  
 Returns a list of parameters list."
since( "0.3.0" ) by( "Lis" )
TestVariantEnumerator resolveParameterizedList (
	"Function to resolve arguments for." FunctionDeclaration declaration,
	"Instance of the test class or `null` if test is performed using top-level function." Object? instance
) {
	value providers = declaration.annotations<Annotation>().narrow<TestVariantProvider>();
	if ( providers.empty ) {
		return EmptyTestVariantEnumerator();
	}
	else if ( providers.size == 1 ) {
		return providers.first?.variants( declaration, instance ) else EmptyTestVariantEnumerator();
	}
	else {
		return CombinedVariantEnumerator( providers*.variants( declaration, instance ).iterator() );
	}
}

"Resolves argument list from `ArgumentsAnnotation`."
since( "0.5.0" ) by( "Lis" )
Anything[] resolveArgumentList (
	"Declaration to resolve list" FunctionDeclaration|ClassDeclaration declaration,
	"Instance of the test class or `null` if not available." Object? instance
) {
	if ( exists argProvider = optionalAnnotation( `ArgumentsAnnotation`, declaration )?.source ) {
		return extractSourceValue<Anything[]>( argProvider, instance );
	}
	else {
		return [];
	}
}
