
"Reports charts."
see( `class Chart` )
by( "Lis" )
shared interface Reporter {
	"Reports with charts."
	shared formal void report( "A list of charts to be reported." Chart* charts );
}
