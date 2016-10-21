
"Represents details of report format."
since( "0.3.0" )
by( "Lis" )
shared class ReportFormat (
	"Delimiter to be used to space columns." shared String delimiter,
	"The minimum number of allowed decimal places for 'category' `Float` formating." shared Integer minCategoryDecimalPlaces,
	"The maximum number of allowed decimal places for 'category' `Float` formating." shared Integer maxCategoryDecimalPlaces,
	"The minimum number of allowed decimal places for 'value' `Float` formating." shared Integer minValueDecimalPlaces,
	"The maximum number of allowed decimal places for 'value' `Float` formating." shared Integer maxValueDecimalPlaces
) {
	
	shared actual String string
			=> "ReportFormat: delimiter '``delimiter``', "
				+ "minCategoryDecimalPlaces ``minCategoryDecimalPlaces``"
				+ "maxCategoryDecimalPlaces ``maxCategoryDecimalPlaces``"
				+ "minValueDecimalPlaces ``minValueDecimalPlaces``"
				+ "maxValueDecimalPlaces ``maxValueDecimalPlaces``";
	
}
