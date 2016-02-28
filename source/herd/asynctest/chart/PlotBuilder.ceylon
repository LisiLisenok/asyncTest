import ceylon.collection {

	ArrayList
}
import java.util.concurrent.locks {

	ReentrantLock
}


"Builds a plot. Allows concurrent access."
by( "Lis" )
class PlotBuilder (
	"Plot title or name." String title
)
		satisfies Plotter
{
	
	"Allow concurrent access."
	ReentrantLock locker = ReentrantLock();
	
	"Points the plot to contain."
	ArrayList<Point> points = ArrayList<Point>();
	
	
	"Plots."
	shared Plot plot() {
		locker.lock();		
		try { return Plot( title, points.sequence() ); }
		finally { locker.unlock(); }
	}
	
	
	shared actual void addPoint( Float category, Float val ) {
		locker.lock();
		try { points.add( Point( category, val ) ); }
		finally { locker.unlock(); }
	}
	
}
