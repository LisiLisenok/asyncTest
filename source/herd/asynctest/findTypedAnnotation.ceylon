import ceylon.language.meta.declaration {

	ClassDeclaration,
	Package,
	AnnotatedDeclaration,
	NestableDeclaration
}
import ceylon.collection {

	ArrayList
}


"Extracts all annotations from which satisfies given `Return` type from the given declaration only."
since( "0.0.1" ) by( "Lis" )
Return[] findTypedAnnotations<Return>( AnnotatedDeclaration declaration ) {
	return declaration.annotations<Annotation>().narrow<Return>().sequence();
}


"Extracts all annotations from chain class-package-module, which satisfies given `Return` type."
since( "0.0.1" ) by( "Lis" )
Return[] findContainerTypedAnnotations<Return>( Package | ClassDeclaration declaration ) {
	ArrayList<Annotation> builder = ArrayList<Annotation>();
	builder.addAll( declaration.annotations<Annotation>() );
	switch ( declaration )
	case ( is ClassDeclaration ) {
		variable ClassDeclaration? exDecl = declaration.extendedType?.declaration;
		while ( exists decl = exDecl ) {
			builder.addAll( decl.annotations<Annotation>() );
			exDecl = decl.extendedType?.declaration;
		}
		builder.addAll( declaration.containingPackage.annotations<Annotation>() );
		builder.addAll( declaration.containingModule.annotations<Annotation>() );
	}
	case ( is Package ) {
		builder.addAll( declaration.container.annotations<Annotation>() );
	}
	return builder.narrow<Return>().sequence();
}


"Returns first annotation found indeclaration or its containers."
since( "0.6.0" ) by( "Lis" )
AnnotationType? findFirstAnnotation<AnnotationType>( Package | NestableDeclaration declaration )
	given AnnotationType satisfies Annotation
{
	switch ( declaration )
	case ( is Package ) {
		return if ( nonempty list = declaration.annotations<AnnotationType>() )
			then list.first
			else if ( nonempty list = declaration.container.annotations<AnnotationType>() )
			then list.first
			else null;
	}
	case ( is NestableDeclaration ) {
		return if ( nonempty list = declaration.annotations<AnnotationType>() )
		then list.first
		else findFirstAnnotation<AnnotationType>( declaration.container );
	}
}
