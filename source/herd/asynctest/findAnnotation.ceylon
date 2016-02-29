import ceylon.language.meta.declaration {

	FunctionDeclaration,
	ClassDeclaration
}
import ceylon.collection {

	ArrayList
}


"Extracts the first annotation from a chain in order - function declaration, class declaration, package, module."
by( "Lis" )
AnnotationType? annotationFromChain<AnnotationType>( FunctionDeclaration functionDeclaration ) 
		given AnnotationType satisfies Annotation
{
	if ( nonempty ann = functionDeclaration.annotations<AnnotationType>() ) {
		return ann.first;
	}
	
	if ( is ClassDeclaration cont = functionDeclaration.container ) {
		variable ClassDeclaration? exDecl = cont;
		while ( exists decl = exDecl ) {
			if ( nonempty ann = decl.annotations<AnnotationType>() ) {
				return ann.first;
			}
			exDecl = decl.extendedType?.declaration;
		}
	}
	
	if ( nonempty ann = functionDeclaration.containingPackage.annotations<AnnotationType>() ) {
		return ann.first;
	}
	else if ( nonempty ann = functionDeclaration.containingModule.annotations<AnnotationType>() ) {
		return ann.first;
	}
	else {
		return null;
	}
}


"Extracts all annotations from chain function-class-package-module, which satisfies given `Return` type."
by( "Lis" )
Return[] findTypedAnnotations<Return>( FunctionDeclaration functionDeclaration ) {
	ArrayList<Annotation> builder = ArrayList<Annotation>();
	builder.addAll( functionDeclaration.annotations<Annotation>() );
	if ( is ClassDeclaration cont = functionDeclaration.container ) {
		variable ClassDeclaration? exDecl = cont;
		while ( exists decl = exDecl ) {
			builder.addAll( decl.annotations<Annotation>() );
			exDecl = decl.extendedType?.declaration;
		}
	}
	builder.addAll( functionDeclaration.containingPackage.annotations<Annotation>() );
	builder.addAll( functionDeclaration.containingModule.annotations<Annotation>() );
	return builder.narrow<Return>().sequence();
}
