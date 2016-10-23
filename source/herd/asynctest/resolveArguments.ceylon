import ceylon.language.meta.declaration {

	FunctionDeclaration,
	ClassDeclaration
}
import ceylon.language.meta.model {

	Type
}
import ceylon.language.meta {

	optionalAnnotation
}


"Resolves a list of type parameters and function arguments provided by [[parameterized]] annotation."
since( "0.3.0" )
by( "Lis" )
{[Type<Anything>[], Anything[]]*} resolveParameterizedList( FunctionDeclaration declaration ) {
	return [for ( provider in declaration.annotations<ParameterizedAnnotation>() )
			for ( arg in provider.arguments() ) arg ];
}


{Anything*} resolveArgumentList( FunctionDeclaration|ClassDeclaration declaration ) {
	if ( exists argProvider = optionalAnnotation( `ArgumentsAnnotation`, declaration ) ) {
		return argProvider.argumentList();
	}
	else {
		return [];
	}
	
}
