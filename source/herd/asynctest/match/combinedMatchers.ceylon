import ceylon.collection {

	ArrayList
}


"Accepted if all matchers from the given list are accepted otherwise rejected."
by( "Lis" )
shared class AllOf<Value>( Matcher<Value>* matchers ) satisfies Matcher<Value>
{
	shared actual Matching match( Value val ) {
		if ( matchers.empty ) {
			return Accepted( "all of '[]'" );
		}
		else {
			ArrayList<Accepted> accepted = ArrayList<Accepted>();
			ArrayList<Rejected> rejected = ArrayList<Rejected>();
		
			for ( matcher in matchers ) {
				value res = matcher.match( val );
				switch ( res )
				case ( is Accepted ) { accepted.add( res ); }
				case ( is Rejected ) { rejected.add( res ); }
			}
			
			if ( rejected.empty ) {
				return Accepted( "all of ``accepted``" );
			}
			else {
				String strRejected = if ( rejected.empty ) then "" else " of ``rejected``";
				String strAccepted = if ( accepted.empty ) then "" else " of ``accepted``";
				return Rejected( "all of: total accepted ``accepted.size````strAccepted``, total rejected ``rejected.size````strRejected``" );
			}
		}
	}
		
	shared actual String string => "all of ``matchers``";
}


"Accepted if one and only one from the given matchers is accepted otherwise rejected."
by( "Lis" )
shared class OneOf<Value>( Matcher<Value>* matchers ) satisfies Matcher<Value>
{
	shared actual Matching match( Value val ) {
		if ( matchers.empty ) {
			return Accepted( "one of '[]'" );
		}
		else {
			ArrayList<Accepted> accepted = ArrayList<Accepted>();
			ArrayList<Rejected> rejected = ArrayList<Rejected>();
			
			for ( matcher in matchers ) {
				value res = matcher.match( val );
				switch ( res )
				case ( is Accepted ) { accepted.add( res ); }
				case ( is Rejected ) { rejected.add( res ); }
			}
			
			if ( accepted.size == 1 ) {
				return Accepted( "one of: ``accepted`` and other rejected ``rejected``" );
			}
			else {
				String strRejected = if ( rejected.empty ) then "" else " of ``rejected``";
				String strAccepted = if ( accepted.empty ) then "" else " of ``accepted``";
				return Rejected( "one of: total accepted ``accepted.size````strAccepted``, total rejected ``rejected.size````strRejected``" );
			}
		}
	}
	
	shared actual String string => "one of ``matchers``";
}


"Accepted if some from the given matchers is accepted and rejected only if all matchers are rejected."
by( "Lis" )
shared class SomeOf<Value>( Matcher<Value>* matchers ) satisfies Matcher<Value>
{
	shared actual Matching match( Value val ) {
		if ( matchers.empty ) {
			return Accepted( "some of '[]'" );
		}
		else {
			ArrayList<Accepted> accepted = ArrayList<Accepted>();
			ArrayList<Rejected> rejected = ArrayList<Rejected>();
			
			for ( matcher in matchers ) {
				value res = matcher.match( val );
				switch ( res )
				case ( is Accepted ) { accepted.add( res ); }
				case ( is Rejected ) { rejected.add( res ); }
			}
			
			if ( accepted.empty ) {
				return Rejected( "some of: ``rejected``" );
			}
			else {
				String strRejected = if ( rejected.empty ) then "" else " of ``rejected``";
				String strAccepted = if ( accepted.empty ) then "" else " of ``accepted``";
				return Accepted( "some of: total accepted ``accepted.size````strAccepted``, total rejected ``rejected.size````strRejected``" );
			}
		}
	}
		
	shared actual String string => "some of ``matchers``";
}
