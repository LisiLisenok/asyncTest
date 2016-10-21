

"Generates `String` representation of an `item`.  
 Used everywhere in `asyncTest` to represent results.
 "
since( "0.4.0" )
by( "Lis" )
shared String stringify( Anything item ) {
	switch ( item )
	case ( is Null ) { return "<null>"; }
	case ( is Character ) { return "'``item``'"; }
	case ( is Float ) { return formatFloat( item, 0, 3 ); }
	case ( is Entry<Object, Anything> ) {
		return "<``stringify( item.key )``->``stringify( item.item )``>";
	}
	case ( is Iterable<Anything> ) {
		if ( is String str = item ) {
			return "\"``str``\"";
		}
		else {
			Integer size = item.size - 1;
			if ( size > 2 ) {
				return "{...}";
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
	else { return item.string; }
}
