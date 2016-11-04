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


"Resolves a list of type parameters and function arguments provided by [[parameterized]] annotation.  
 Returns a list of parameters list."
since( "0.3.0" ) by( "Lis" )
ParametersList[] resolveParameterizedList( FunctionDeclaration declaration ) {
	return [for ( provider in declaration.annotations<ParameterizedAnnotation>() )
	ParametersList( provider.arguments(), provider.maxFailedVariants ) ];
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


"Represents a one `parameterized` annotation."
since( "0.3.0" ) by( "Lis" )
class ParametersList (
	"Variants parameters." shared {[Type<Anything>[], Anything[]]*} variants,
	"Stop testing when a number of variants failed." shared Integer maxFailedVariants
) {}
