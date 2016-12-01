import ceylon.language.meta.declaration {
	FunctionOrValueDeclaration,
	FunctionDeclaration,
	ValueDeclaration
}
import ceylon.language.meta {
	type
}


"Calls [[source]] to get source value."
since( "0.6.0" ) by( "Lis" )
Result extractSourceValue<Result>( FunctionOrValueDeclaration source, Object? instance ) {
	switch ( source )
	case ( is FunctionDeclaration ) {
		value args = resolveArgumentList( source, instance ); 
		return if ( !source.toplevel, exists instance ) 
		then source.memberApply<Nothing, Result, Nothing>( type( instance ) ).bind( instance ).apply( *args )
		else source.apply<Result, Nothing>().apply( *args );
	}
	case ( is ValueDeclaration ) {
		return if ( !source.toplevel, exists instance ) 
		then source.memberApply<Nothing, Result>( type( instance ) ).bind( instance ).get()
		else source.apply<Result>().get();
	}
}
