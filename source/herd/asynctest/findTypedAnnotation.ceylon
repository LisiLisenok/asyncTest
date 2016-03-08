import ceylon.language.meta.declaration {

	ClassDeclaration,
	Package,
	AnnotatedDeclaration
}
import ceylon.collection {

	ArrayList
}


"Extracts all annotations from which satisfies given `Return` type from the given declaration only."
by( "Lis" )
Return[] findTypedAnnotations<Return>( AnnotatedDeclaration declaration ) {
	ArrayList<Annotation> builder = ArrayList<Annotation>();
	builder.addAll( declaration.annotations<Annotation>() );
	return builder.narrow<Return>().sequence();
}


"Extracts all annotations from chain class-package-module, which satisfies given `Return` type."
by( "Lis" )
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
