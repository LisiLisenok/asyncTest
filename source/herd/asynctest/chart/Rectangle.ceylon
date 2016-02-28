
"Rectangle in 2D."
by( "Lis" )
shared class Rectangle (
	shared Float left,
	shared Float right,
	shared Float bottom,
	shared Float top
)
		extends Object()
{
	shared Float width => right - left;
	shared Float height => top - bottom;
	
	"Returns rectangle which contains both this and other"
	shared Rectangle union( Rectangle other )
			=> Rectangle (
		if ( left < other.left ) then left else other.left,
		if ( right > other.right ) then right else other.right,
		if ( bottom < other.bottom ) then bottom else other.bottom,
		if ( top > other.top ) then top else other.top
	);
	
	
	shared actual Boolean equals( Object that ) {
		if ( is Rectangle that ) {
			return	left == that.left && 
					right == that.right && 
					bottom == that.bottom && 
					top == that.top;
		}
		else {
			return false;
		}
	}
	
	shared actual Integer hash {
		variable value hash = 1;
		hash = 31 * hash + left.hash;
		hash = 31 * hash + right.hash;
		hash = 31 * hash + bottom.hash;
		hash = 31 * hash + top.hash;
		return hash;
	}
	
}
