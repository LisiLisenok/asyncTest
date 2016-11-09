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
TestVariantEnumerator resolveParameterizedList( FunctionDeclaration declaration ) {
	value providers = declaration.annotations<Annotation>().narrow<TestVariantProvider>();
	if ( providers.empty ) {
		return EmptyTestVariantEnumerator();
	}
	else if ( providers.size == 1 ) {
		return providers.first?.variants() else EmptyTestVariantEnumerator();
	}
	else {
		return CombinedVariantEnumerator( providers*.variants().iterator() );
	}

}

"Resolves argument list from `ArgumentsAnnotation`."
since( "0.5.0" ) by( "Lis" )
Anything[] resolveArgumentList( FunctionDeclaration|ClassDeclaration declaration ) {
	return optionalAnnotation( `ArgumentsAnnotation`, declaration )?.argumentList() else [];
}
