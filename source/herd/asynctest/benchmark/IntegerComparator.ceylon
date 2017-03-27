import java.util {
	Comparator
}


"Java comparator of Ceylon `Integer`."
since( "0.7.0" ) by( "Lis" )
class IntegerComparator() satisfies Comparator<Integer> {
	
	shared actual Integer compare( Integer first, Integer second ) 
		=>  switch ( first <=> second )
			case ( equal )    0
			case ( larger )   1
			case ( smaller ) -1;

	
	shared actual Boolean equals( Object that ) => (super of Basic).equals(that);
	
}
