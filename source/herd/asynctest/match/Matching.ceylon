

"Indicates matching state: accepted or rejected."
by( "Lis" )
shared abstract class Matching() of Accepted | Rejected {}


"Matching is accepted, i.e. satisfied."
by( "Lis" )
shared final class Accepted( String message ) extends Matching() {
	shared actual String string => "accepted->'``message``'";
}


"Matching is rejected, i.e. not satisfied."
by( "Lis" )
shared final class Rejected( String message ) extends Matching() {
	shared actual String string => "rejected->'``message``'";
}
