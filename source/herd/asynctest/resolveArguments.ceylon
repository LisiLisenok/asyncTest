
import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import ceylon.language.meta.model {

	Type
}
import ceylon.collection {

	ArrayList
}


"Resolves a list of type parameters and function arguments provided by [[parameterized]] annotation."
since( "0.3.0" )
by( "Lis" )
{[Type<Anything>[], Anything[]]*} resolveArgumentList( FunctionDeclaration declaration ) {
	value typeArgProviders = declaration.annotations<ParameterizedAnnotation>();
	Integer typeArgSize = typeArgProviders.size;
	if ( typeArgSize == 0 ) {
		return [];
	}
	else {
		ArrayList<[Type<Anything>[], Anything[]]> ret = ArrayList<[Type<Anything>[], Anything[]]>();
		for ( provider in typeArgProviders ) {
			ret.addAll( provider.arguments() );
		}
		return ret.sequence();
	}
}
