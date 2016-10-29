import ceylon.language.meta.model {
	Type,
	IntersectionType,
	ClassOrInterface,
	UnionType
}


"Returns type name without module.package"
since( "0.6.0" ) by( "Lis" )
shared String typeName( Type<Anything> t ) {
	if ( is ClassOrInterface<> t ) {
		StringBuilder builder = StringBuilder();
		builder.append( t.declaration.name );
		if ( nonempty args = t.typeArgumentList ) {
			builder.append( "<" );
			Integer size = args.size - 1;
			for ( index->arg in args.indexed ) {
				builder.append( typeName( arg ) );
				if ( index < size ) {
					builder.append( ", " );
				}
			}
			builder.append( ">" );
		}
		return builder.string;
	}
	else if ( is UnionType<> t ) {
		StringBuilder builder = StringBuilder();
		Integer size = t.caseTypes.size - 1;
		for ( index->item in t.caseTypes.indexed ) {
			builder.append( typeName( item ) );
			if ( index < size ) {
				builder.append( "|" );
			}
		}
		return builder.string;
	}
	else if ( is IntersectionType<> t ) {
		StringBuilder builder = StringBuilder();
		Integer size = t.satisfiedTypes.size - 1;
		for ( index->item in t.satisfiedTypes.indexed ) {
			builder.append( typeName( item ) );
			if ( index < size ) {
				builder.append( "&" );
			}
		}
		return builder.string;
	}
	else {
		return "Nothing";
	}
}
