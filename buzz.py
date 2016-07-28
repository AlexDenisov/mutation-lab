#! /usr/bin/env python

import os
import sys
import unittest

try:
    import json
except ImportError:
    import simplejson as json

class CompileDatabaseParser(object):
    def __init__(self, database_path):
        self.database_path = database_path

    def dump_commands_count(self):
        print(len(self.load_database()))

    def get_commands_for_target(self, target):
        tests_root_dir = "./llvm/unittests"
        return []

    def load_database(self):
        with open(self.database_path, 'r') as f:
            return json.loads(f.read())

class HelloTests(unittest.TestCase):
    def test(self):
        greeting = "Hello"
        self.assertEqual("Hello", greeting)

if __name__ == '__main__':
#    unittest.main()

    worker = CompileDatabaseParser("./llvm_build/compile_commands.json")
    commands = worker.get_commands_for_target("ADT")
    print(commands)

