import ceylon.language.meta.declaration {

	ClassDeclaration
}
import ceylon.language.meta {

	optionalAnnotation
}


"Instantiates an object from class declaration with empty initializer list."
by( "Lis" )
Object instantiateFromClassDeclaration( ClassDeclaration declaration ) {
	if ( declaration.anonymous ) {
		assert ( exists objectInstance = declaration.objectValue?.get() );
		return objectInstance;
	}
	else if ( exists argProvider = optionalAnnotation( `ArgumentsAnnotation`, declaration ) ) {
		return declaration.instantiate( [], *argProvider.arguments() );
	}
	else {
		return declaration.instantiate( [] );
	}
}
