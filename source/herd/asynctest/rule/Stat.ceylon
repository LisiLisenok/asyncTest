
"Statistic summary from some variate values stream."
by( "Lis" ) since( "0.6.0" )
shared class Stat (
	"Minimum of the values that have been statisticaly treated."
	shared Float min,
	"Maximum of the values that have been statisticaly treated."
	shared Float max,
	"Mean value."
	shared Float mean,
	"Returns standard deviation of the values that have been statisticaly treated.
	 Standard deviation is `variance^0.5`."
	shared Float standardDeviation,		
	"The number of the values that have been statisticaly treated."
	shared Integer size
) {
	"Variance of the values that have been statisticaly treated.
	 The variance is mean((x-mean(x))^2)."
	shared Float variance => standardDeviation * standardDeviation;
}
