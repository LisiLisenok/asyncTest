

"Formats `Float` to `String`."
String formatFloatToString (
	"Number to be formated." Float float,
	"The minimum number of allowed decimal places for `Float` formating." Integer minDecimalPlaces,
	"The maximum number of allowed decimal places for `Float` formating." Integer maxDecimalPlaces
) {
	if ( float.undefined || float.infinite ) {
		return float.string;
	}
	else if ( maxDecimalPlaces > 0 ) {
		Integer min = if ( maxDecimalPlaces > minDecimalPlaces ) then minDecimalPlaces else maxDecimalPlaces;
		Float pow = 10.0.powerOfInteger( maxDecimalPlaces );
		variable String fractional = ( float.fractionalPart.magnitude * pow + 0.5 / pow ).integer.string;
		variable Integer size = fractional.size;
		if ( size < maxDecimalPlaces ) {
			fractional = "0".repeat( maxDecimalPlaces - size ) + fractional;
		}
		fractional = fractional.trimTrailing( '0'.equals );
		size = fractional.size;
		if ( size < min ) {
			fractional = fractional + "0".repeat( min - size );
		}
		if ( fractional.empty ) {
			return ( float + float.sign * 0.5 ).integer.string;
		}
		else {
			return float.integer.string + "." + fractional;
		}
	}
	else {
		return ( float + float.sign * 0.5 ).integer.string;
	}
}
