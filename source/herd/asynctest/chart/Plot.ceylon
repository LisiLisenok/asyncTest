

"A one plot as a list of points."
by( "Lis" )
shared class Plot (
	"Plot title or name."
	shared String title,
	"Points representing this plot."
	shared Point[] points
) {
	
	"Calculates plot bounds."
	shared Rectangle bounds() {		
		if ( nonempty points ) {
			variable Float left = runtime.maxFloatValue;
			variable Float right = runtime.minFloatValue;
			variable Float bottom = runtime.maxFloatValue;
			variable Float top = runtime.minFloatValue;
			for ( item in points ) {
				if ( item.category < left ) { left = item.category; }
				if ( item.category > right ) { right = item.category; }
				if ( item.val < bottom ) { bottom = item.val; }
				if ( item.val > top ) { top = item.val; }
			}
			return Rectangle( left, right, bottom, top );
		}
		else {
			return Rectangle( 0.0, 0.0, 0.0, 0.0 );
		}
	}
}
