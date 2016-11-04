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
Iterator<TestVariant> resolveParameterizedList( FunctionDeclaration declaration ) {
	value providers = declaration.annotations<Annotation>().narrow<TestVariantProvider>();
	if ( providers.empty ) {
		return [emptyTestVariant].iterator();
	}
	else if ( providers.size == 1 ) {
		if ( exists f = providers.first ) {
			return f.variantsIterator();
		}
		else {
			return [emptyTestVariant].iterator();
		}
	}
	else {
		return CombinedVariantProvider( providers.map( ( TestVariantProvider provider ) => provider.variantsIterator() ).iterator() );
	}

}

"Resolves argument list from `ArgumentsAnnotation`."
since( "0.5.0" ) by( "Lis" )
{Anything*} resolveArgumentList( FunctionDeclaration|ClassDeclaration declaration ) {
	if ( exists argProvider = optionalAnnotation( `ArgumentsAnnotation`, declaration ) ) {
		return argProvider.argumentList();
	}
	else {
		return [];
	}
}
