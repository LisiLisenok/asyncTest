
import herd.asynctest.parameterization {
	TestVariant
}


{TestVariant*} comparisonStrings => {
	TestVariant([], ["Frodo", "Frodo"]),
	TestVariant([], ["Frodo", "Bilbo"]),
	TestVariant([], ["Bilbo", "Frodo"]),
	TestVariant([], ["Bilbo", "Bilbo"])
};


{TestVariant*} combinedComparisonStrings => {
	TestVariant([], ["Frodo", "Bilbo", "Hobbit"]),
	TestVariant([], ["Bilbo", "Frodo", "Hobbit"]),
	TestVariant([], ["Hobbit", "Bilbo", "Frodo"])
};


{TestVariant*} subListStrings => {
	TestVariant([], ["Frodo", "Frodo Hobbit"]),
	TestVariant([], ["Frodo", "Hobbit Frodo"]),
	TestVariant([], ["Frodo Hobbit", "Frodo"]),
	TestVariant([], ["Frodo", "Bilbo Hobbit"]),
	TestVariant([], ["Frodo Hobbit", "Hobbit"])
};


{TestVariant*} valueEqualityString => {
	TestVariant([], ["Frodo"]),
	TestVariant([], ["Bilbo"]),
	TestVariant([], ["Hobbit"])
};


{TestVariant*} valueEqualityInteger => {
	TestVariant([], [1]),
	TestVariant([], [2]),
	TestVariant([], [3])
};
