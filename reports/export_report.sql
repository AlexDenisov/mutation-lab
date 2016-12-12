.mode csv
.header on

.output mutation_points.csv
select rowid,* from mutation_point;

.output mutation_results.csv
select rowid,* from mutation_result;

.output execution_results.csv
select rowid,* from execution_result;

.output tests.csv
select rowid,* from test;

