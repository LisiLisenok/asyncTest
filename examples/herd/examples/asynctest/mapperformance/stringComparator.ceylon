import java.util {

	Comparator
}

"string comparator used for java TreeMap"
object stringComparator extends Basic() satisfies Comparator<String> {
	shared actual Integer compare( String? t, String? t1 ) {
		assert ( exists t );
		assert ( exists t1 );
		switch ( t <=> t1 )
		case ( smaller ) { return -1; }
		case ( equal ) { return 0; }
		case ( larger ) { return 1; }
	}
	
	shared actual Boolean equals( Object that ) => ( super of Basic ).equals( that );
}
