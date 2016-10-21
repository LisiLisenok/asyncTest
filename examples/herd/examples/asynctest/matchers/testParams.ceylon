

{[[], [String, String]]*} comparisonStrings => {
	[[], ["Frodo", "Frodo"]],
	[[], ["Frodo", "Bilbo"]],
	[[], ["Bilbo", "Frodo"]],
	[[], ["Bilbo", "Bilbo"]]
};


{[[], [String, String, String]]*} combinedComparisonStrings => {
	[[], ["Frodo", "Bilbo", "Hobbit"]],
	[[], ["Bilbo", "Frodo", "Hobbit"]],
	[[], ["Hobbit", "Bilbo", "Frodo"]]
};


{[[], [String, String]]*} subListStrings => {
	[[], ["Frodo", "Frodo Hobbit"]],
	[[], ["Frodo", "Hobbit Frodo"]],
	[[], ["Frodo Hobbit", "Frodo"]],
	[[], ["Frodo", "Bilbo Hobbit"]],
	[[], ["Frodo Hobbit", "Hobbit"]]
};
