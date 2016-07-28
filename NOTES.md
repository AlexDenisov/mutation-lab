### Get compilation_database.json

```
mkdir build
cd build
cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DLLVM_TARGETS_TO_BUILD="X86" ../llvm
ninja llvm-tblgen
cd ..
cp build/compile_commands.json ./
```

### Get list of commands required to build a target

```
ninja -t commands ADTTests
```

### Get list of files needed for a target

```
ninja -t commands ADTTests | awk '/^\/Applications/ { print $NF } '
```

### Patch commands to replace output file name

```
ninja -t commands ADTTests | grep -v "^:" | sed 's/\(-o .*\)\.o/\1.ll/'
```

### Patch commands to replace output file name and add `-S -emit-llvm`

```
ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.ll/' -e 's/$/ -S -emit-llvm/'
```

### Evaluate patched commands

```
mkdir -p unittests/ADT/CMakeFiles/ADTTests.dir
ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.ll/' -e 's/\(\/App.*\)$/\1 -S -emit-llvm/' > commands.sh
sh commands.sh
```

