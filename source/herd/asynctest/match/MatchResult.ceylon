

"Represents a result of matching operation:
 * state - accepted or rejected
 * `String` message with operation details
 "
by( "Lis" )
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
	
	
	"Combines this and other by `logical and`."
	shared MatchResult and( MatchResult other )
		=> MatchResult( "(``string``) and (``other.string``)", accepted && other.accepted );
	
	"Combines this and other by `logical or`."
	shared MatchResult or( MatchResult other )
		=> MatchResult( "(``string``) or (``other.string``)", accepted || other.accepted );
	
	"Combines this and other by `logical xor`."
	shared MatchResult xor( MatchResult other )
		=> MatchResult (
			"(``string``) xor (``other.string``)",
			( accepted || other.accepted ) && ( !accepted || !other.accepted )
		);
	
	"Reverts this matcher."
	shared MatchResult not() => MatchResult( "not(``string``)", !accepted );
	
	
	shared actual Boolean equals(Object that) {
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
