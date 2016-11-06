import ceylon.language.meta.declaration {
	NestableDeclaration
}


"Extracts timeout for the declaration searching `timeout` annotation
 on the declaration and on all upper-level containers. The lower-level has more priority.  
 Returns -1 if no `timeout` annotation found."
see( `function timeout` )
since( "0.6.0" ) by( "Lis" )
Integer extractTimeout( NestableDeclaration declaration ) {
	return if ( exists ann = findFirstAnnotation<TimeoutAnnotation>( declaration ) )
	then ann.timeoutMilliseconds else -1;
}