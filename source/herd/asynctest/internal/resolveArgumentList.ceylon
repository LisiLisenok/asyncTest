import ceylon.language.meta.declaration {

	ClassDeclaration,
	FunctionDeclaration
}
import ceylon.language.meta {

	optionalAnnotation
}
import herd.asynctest {
	ArgumentsAnnotation
}


"Resolves argument list from `ArgumentsAnnotation`."
since( "0.5.0" ) by( "Lis" )
shared Anything[] resolveArgumentList (
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
