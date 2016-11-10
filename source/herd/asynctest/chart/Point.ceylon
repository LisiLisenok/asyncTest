
"A one point on a plot."
see( `class Plot` )
since( "0.3.0" )
by( "Lis" )
shared class Point
(
	"Position on categoty axis." shared Float category,
	"Position on value axis." shared Float val
) {
	
	shared actual Boolean equals( Object that ) {
		return if ( is Point that )
			then category == that.category && val == that.val
			else false;
	}
	
	shared actual Integer hash => 31 * ( 31 + category.hash ) + val.hash;
	
	shared actual String string => "Point of x=``category``, y=``val``";
	
}
