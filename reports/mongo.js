db.mutation_points.aggregate([
	{ $lookup : { from : mutation_results, localField: unique_id, foreignField : mutation_point_id, as : result }}
])

db.mutation_points.aggregate([ { $group : { "_id" : "$function_name", mutation_points: { $push : "$$ROOT" } }} ]).pretty()

db.execution_results.createIndex({ 'rowid' : 1})
db.mutation_points.createIndex({ 'unique_id' : 1 })
db.mutation_results.createIndex({ 'mutation_point_id' : 1})
db.tests.createIndex({ 'test_name' : 1 })

db.mutation_points.aggregate([
	{ $lookup : { from : "mutation_results", localField: "unique_id", foreignField : "mutation_point_id", as : "results" }},
	{ $unwind : "$results" },
	{ $lookup : { from : "execution_results", localField: "results.execution_result_id", foreignField : "rowid", as : "results.execution_result" }},
	{ $unwind : "$results.execution_result" },
	{ $lookup : { from : "tests", localField: "results.test_id", foreignField : "test_name", as : "results.test" }},
	{ $unwind : "$results.test" },
	{ $lookup : { from : "execution_results", localField: "results.test.execution_result_id", foreignField : "rowid", as : "results.test.execution_result" }},
	{ $group : {
		"_id" : "$_id",
		results : { $push : "$results" },
		rowid : { $first : "$rowid" },
		"mutation_operator" : { $first : "$mutation_operator" },
		"module_name" : { $first : "$module_name"},
		"function_name" : { $first : "$function_name"},
		"function_index" : { $first : "$function_index"},
		"basic_block_index" : { $first : "$basic_block_index"},
		"instruction_index" : { $first : "$instruction_index"},
		"filename" : { $first : "$filename"},
		"line_number" : { $first : "$line_number"},
		"column_number" : { $first : "$column_number"},
		"unique_id" : { $first : "$unique_id"},
		 }},
	{ $group : { _id : "$function_name", "mutation_points" : { $push : "$$ROOT" } } },
])

db.grouped_by_location.aggregate([
	{ $match : { "_id" : "_ZN4llvm6detail9IEEEFloat10initializeEPKNS_12fltSemanticsE" } },
	{ $unwind : "$mutation_points" },
	{ $group : { _id: "$mutation_points.results.execution_result.status", count : { $sum : 1 } } }
]).pretty()
















