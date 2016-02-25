import ceylon.test.engine.spi {

	ArgumentListProvider,
	ArgumentProviderContext,
	ArgumentProvider
}
import ceylon.language.meta.declaration {

	FunctionDeclaration
}
import ceylon.test {

	TestDescription
}
import ceylon.language.meta {

	type
}


"Resolves a list of arguments provided by [[ArgumentListProvider]] like [[ceylon.test::parameters]] annotation."
by( "Lis" )
{Anything[]*} resolveArgumentList( FunctionDeclaration declaration ) {
	value argListProviders = declaration.annotations<Annotation>().narrow<ArgumentListProvider>();
	Integer size = argListProviders.size;
	if ( size == 1 ) {
		 assert ( exists provider = argListProviders.first );
		 return provider.argumentLists( ArgumentProviderContext( TestDescription( "", declaration ), declaration ) );
	}
	else if ( size > 1 )  {
		value argListProviderNames = argListProviders.map( ( e ) => type( e ).declaration.name );
		throw Exception( "function ``declaration.qualifiedName`` has multiple ArgumentListProviders: ``argListProviderNames``" );
	}
	else {
		return [];
	}
}


"Resolves arguments provided by [[ArgumentProvider]] like [[ceylon.test::parameters]] annotation."
by( "Lis" )
{Anything*} resolveArguments( FunctionDeclaration declaration ) {
	value argProviders = declaration.annotations<Annotation>().narrow<ArgumentProvider>();
	Integer size = argProviders.size;
	if ( size == 1 ) {
		assert ( exists provider = argProviders.first );
		return provider.arguments( ArgumentProviderContext( TestDescription( "", declaration ), declaration ) );
	}
	else if ( size > 1 )  {
		value argProviderNames = argProviders.map( ( e ) => type( e ).declaration.name );
		throw Exception( "function ``declaration.qualifiedName`` has multiple ArgumentProviders: ``argProviderNames``" );
	}
	else {
		return [];
	}
}
