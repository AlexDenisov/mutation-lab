#!/usr/bin/env bash

rm -f mutation_points.csv
rm -f mutation_results.csv
rm -f execution_results.csv
rm -f tests.csv

mongo --eval "db.execution_results.drop()"
mongo --eval "db.mutation_points.drop()"
mongo --eval "db.mutation_results.drop()"
mongo --eval "db.tests.drop()"

sqlite3 $1 < export_report.sql

function import() {
  cmd="mongoimport --collection $1 --headerline --type csv $1.csv --drop"
  echo $cmd
  $cmd
}

import tests
import mutation_results
import mutation_points
import execution_results

mongo --eval "db.execution_results.createIndex({ 'rowid' : 1})"
mongo --eval "db.mutation_points.createIndex({ 'unique_id' : 1 })"
mongo --eval "db.mutation_results.createIndex({ 'mutation_point_id' : 1})"
mongo --eval "db.tests.createIndex({ 'test_name' : 1 })"

