

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
)
		extends Object ()
{
	
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
	
	"Combines this and other by `logical and`."
	shared MatchResult and( MatchResult* other ) => combineWith( "&&", andBoolean, *other );
	
	"Combines this and other by `logical or`."
	shared MatchResult or( MatchResult* other ) => combineWith( "||", orBoolean, *other );

	
	"Reverts this matcher."
	shared MatchResult not() => MatchResult( "not(``string``)", !accepted );
	
	
	shared actual Boolean equals( Object that ) {
		if ( is MatchResult that ) {
			return message == that.message && accepted == that.accepted;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash {
		variable value hash = 1;
		hash = 31*hash + message.hash;
		hash = 31*hash + accepted.hash;
		return hash;
	}
	
}
