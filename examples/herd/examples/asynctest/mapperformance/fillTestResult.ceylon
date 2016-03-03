import herd.asynctest.chart {

	Plotter
}
import herd.asynctest {

	AsyncTestContext
}
import herd.asynctest.match {

	Greater
}


"Fills results of testing to context.  
 Returns `String` to complete test with."
String fillTestResult (
	"Context results to be filled in." AsyncTestContext context,
	"Results of Ceylon test." Float[3] | Throwable ceylonResult,
	"Results of Java test." Float[3] | Throwable javaResult,
	"Tolerance to compare Ceylon to Java." Float tolerance,
	"Total number of items in the map." Integer totalItems,
	"Title of ratio chart." String ratioChartTitle
) {
	
	if ( is Throwable ceylonResult ) {
		context.abort( ceylonResult );
		return "";
	}
	else if ( is Throwable javaResult ) {
		context.abort( javaResult );
		return "";
	}
	else {
		// Ceylon / Java ratios
		Float putRatio = ceylonResult[0] / javaResult[0];
		Float getRatio = ceylonResult[1] / javaResult[1];
		Float removeRatio = ceylonResult[2] / javaResult[2];
		
		// Formated string representation of ratios
		String putRatioStr = formatFloat( putRatio, 2, 2 );
		String getRatioStr = formatFloat( getRatio, 2, 2 );
		String removeRatioStr = formatFloat( removeRatio, 2, 2 );
		
		// fail the test if ratio is greater then target
		/*String putMessage = "'put' Ceylon / Java ratio of ``putRatioStr`` is greater than target ``targetRatio``";
		String putSucceed = "'put' Ceylon / Java ratio of ``putRatioStr`` is not greater than target ``targetRatio``";
		context.assertFalse( putRatio > targetRatio, putMessage, putMessage, putSucceed );
		String getMessage = "'get' Ceylon / Java ratio of ``getRatioStr`` is greater than target ``targetRatio``";
		String getSucceed = "'get' Ceylon / Java ratio of ``getRatioStr`` is not greater than target ``targetRatio``";
		context.assertFalse( getRatio > targetRatio, getMessage, getMessage, getSucceed );
		String removeMessage = "'remove' Ceylon / Java ratio of ``removeRatioStr`` is greater than target ``targetRatio``";
		String removeSucceed = "'remove' Ceylon / Java ratio of ``removeRatioStr`` is not greater than target ``targetRatio``";
		context.assertFalse( removeRatio > targetRatio, removeMessage, removeMessage, removeSucceed );*/
		
		context.assertThat( putRatio, Greater( 1.0 + tolerance ), "'put' Ceylon / Java ratio" );
		context.assertThat( getRatio, Greater( 1.0 + tolerance ), "'get' Ceylon / Java ratio" );
		context.assertThat( removeRatio, Greater( 1.0 + tolerance ), "'remove' Ceylon / Java ratio" );
		
		String putPlotterName = ratioChartTitle + titles.titlesDelimiter + titles.put;
		String getPlotterName = ratioChartTitle + titles.titlesDelimiter + titles.get;
		String removePlotterName = ratioChartTitle + titles.titlesDelimiter + titles.remove;
		
		if ( exists putPlotter = context.get<Plotter>( putPlotterName ),
			exists getPlotter = context.get<Plotter>( getPlotterName ),
			exists removePlotter = context.get<Plotter>( removePlotterName )
		) {
			putPlotter.addPoint( totalItems.float, putRatio );
			getPlotter.addPoint( totalItems.float, getRatio );
			removePlotter.addPoint( totalItems.float, removeRatio );
		}
		else {
			context.abort( Exception( "plotter with name '``ratioChartTitle``-XXX' doesn't exists" ) );
		}
		
		// completing the test, argument will be used only if test is succeeded
		return "all 'put' of ``putRatioStr``, 'get' of ``getRatioStr`` and 'remove' of ``removeRatioStr`` "
				+ "Ceylon / Java ratios are less then target ``1 + tolerance``";
	}
	
}
