import ceylon.language.meta.model {

	Type
}


"Generates `String` representation of an `item`.  
 Used everywhere in `asyncTest` to represent results.
 "
since( "0.4.0" ) by( "Lis" )
shared String stringify( Anything item ) {
	//switch ( item )
	if ( is Null item ) { return "<null>"; }
	else if ( is Character item ) { return "'``item``'"; }
	else if ( is Float item ) { return Float.format( item, 0, 3 ); }
	else if ( is Entry<Object, Anything> item ) {
		return "<``stringify( item.key )``->``stringify( item.item )``>";
	}
	else if ( is Iterable<Anything> item ) {
		if ( is String str = item ) {
			return "\"``str``\"";
		}
		else {
			Integer size = item.size - 1;
			if ( size > 2 ) {
				return "{size=``size``}";
			}
			else {
				StringBuilder builder = StringBuilder();
				builder.append( "{" );
				for ( index->element in item.indexed ) {
					builder.append( stringify( element ) );
					if ( index != size ) { builder.append( ", " ); }
				}
				builder.append( "}" );
				return builder.string;
			}
		}
	}
	else if ( is Type<Anything> item ) {
		return typeName( item );
	}
	else { return item.string; }
}
