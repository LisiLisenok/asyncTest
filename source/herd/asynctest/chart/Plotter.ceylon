
"Plot builder."
since( "0.3.0" )
by( "Lis" )
shared interface Plotter {
	
	"Adds point to the plot."
	shared formal void addPoint (
		"Point category or abscissa." Float category,
		"Point value or ordinate." Float val
	);
	
}
