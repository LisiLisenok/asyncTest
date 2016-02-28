
"Description of a chart:
 * title
 * category axis title
 * value axis title
 * plot titles
 "
by( "Lis" )
shared class ChartDescription (
	"Chart title." shared String chartTitle,
	"Title of category axis." shared String categoryTitle,
	"Title of value axis." shared String valueTitle,
	"A list of plot titles the chart contains." shared String[] plotTitles,
	"Optional format to be used to report the chart" shared ReportFormat? format = null
) {}
