import herd.asynctest {

	FunctionParameters
}


{FunctionParameters*} comparisonStrings => {
	FunctionParameters([], ["Frodo", "Frodo"]),
	FunctionParameters([], ["Frodo", "Bilbo"]),
	FunctionParameters([], ["Bilbo", "Frodo"]),
	FunctionParameters([], ["Bilbo", "Bilbo"])
};


{FunctionParameters*} combinedComparisonStrings => {
	FunctionParameters([], ["Frodo", "Bilbo", "Hobbit"]),
	FunctionParameters([], ["Bilbo", "Frodo", "Hobbit"]),
	FunctionParameters([], ["Hobbit", "Bilbo", "Frodo"])
};


{FunctionParameters*} subListStrings => {
	FunctionParameters([], ["Frodo", "Frodo Hobbit"]),
	FunctionParameters([], ["Frodo", "Hobbit Frodo"]),
	FunctionParameters([], ["Frodo Hobbit", "Frodo"]),
	FunctionParameters([], ["Frodo", "Bilbo Hobbit"]),
	FunctionParameters([], ["Frodo Hobbit", "Hobbit"])
};
