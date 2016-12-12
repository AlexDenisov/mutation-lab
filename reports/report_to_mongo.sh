#!/usr/bin/env bash

rm -f mutation_points.csv
rm -f mutation_results.csv
rm -f execution_results.csv
rm -f tests.csv

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

