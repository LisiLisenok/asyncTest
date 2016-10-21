
"Reports charts."
see( `class Chart` )
since( "0.3.0" )
by( "Lis" )
shared interface Reporter {
	"Reports with charts."
	shared formal void report( "A list of charts to be reported." Chart* charts );
}
