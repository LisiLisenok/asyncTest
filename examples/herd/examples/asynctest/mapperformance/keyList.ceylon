

"Returns a list of keys with total number of keys as percentage from max index."
String[] keyList( String prefix, Integer max, Float percent ) {
	Integer p = ( percent * max ).integer;
	return [for ( index in 0 : p ) prefix + ( index / p * max ).string];
}