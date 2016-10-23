

"Summary result of variant execution."
since( "0.0.1" )
by( "Lis" )
final class VariantTestOutput (
	"Outputs from test." shared TestOutput[] outs,
	"Total time elapsed on this test." shared Integer totalElapsedTime,
	"`true` if test initialization and disposing have been successfully proceeded." shared Boolean proceeded
) {
}