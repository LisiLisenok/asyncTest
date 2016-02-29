
"A one point on a plot."
see( `class Plot` )
by( "Lis" )
shared class Point
(
	"Position on categoty axis." shared Float category,
	"Position on value axis." shared Float val
)
	extends Object()
{
	
	shared actual Boolean equals( Object that ) {
		if ( is Point that ) {
			return	category == that.category && 
					val == that.val;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash {
		variable value hash = 1;
		hash = 31 * hash + category.hash;
		hash = 31 * hash + val.hash;
		return hash;
	}
	
	
	shared actual String string => "Point of x=``category``, y=``val``";
	
}
