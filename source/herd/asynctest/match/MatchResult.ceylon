

"Represents a result of matching operation:
 * state - accepted or rejected
 * `String` message with operation details
 "
since( "0.4.0" ) by( "Lis" )
shared final class MatchResult (
	"Message of the match operation."
	String message,
	"`true` if matching is accepted and `false` if rejected."
	shared Boolean accepted
) {
	
	shared actual String string
		=> if ( accepted ) then "accepted->'``message``'" else "rejected->'``message``'";
	
	Boolean andBoolean( Boolean x, Boolean y ) => x && y;
	Boolean orBoolean( Boolean x, Boolean y ) => x || y;
	
	"Combines the given matcher with others using `combine`."
	MatchResult combineWith( String operationSymbol, Boolean(Boolean, Boolean) combine, MatchResult* other ) {
		if ( other.empty ) {
			return this;
		}
		else {
			StringBuilder str = StringBuilder();
			str.append( "(``string``)" );
			variable Boolean ret = accepted;
			for ( item in other ) {
				str.append( "``operationSymbol``(``item.string``)" );
				ret = combine( ret, item.accepted );
			}
			return MatchResult( "``str.string``", ret );
		}
	}
	
	"Combines all from this and other by _logical and_."
	shared MatchResult and( MatchResult* other ) => combineWith( "&&", andBoolean, *other );
	
	"Combines all from this and other by _logical or_."
	shared MatchResult or( MatchResult* other ) => combineWith( "||", orBoolean, *other );

	
	"Reverts this matcher."
	shared MatchResult not() => MatchResult( "not(``string``)", !accepted );
	
	
	shared actual Boolean equals( Object that ) {
		return if ( is MatchResult that )
			then message == that.message && accepted == that.accepted
			else false;
	}
	
	shared actual Integer hash => 31*message.hash + accepted.hash;
	
}
