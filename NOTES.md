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

### Evaluate patched commands (human readable LLVM IR)

```
mkdir -p unittests/ADT/CMakeFiles/ADTTests.dir
ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.ll/' -e 's/\(\/App.*\)$/\1 -S -emit-llvm/' > commands_ll.sh
sh commands_ll.sh
```

### Evaluate patched commands (bitcode)

```
mkdir -p unittests/ADT/CMakeFiles/ADTTests.dir
ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.bc/' -e 's/\(\/App.*\)$/\1 -emit-llvm/' > commands_bc.sh
sh commands_bc.sh
```

### Gather all LLVM IR files

Some files (Error/FoldingSet) has the same name in different folders

```
cd build
mv ./lib/Support/CMakeFiles/LLVMSupport.dir/Error{,_Support}.cpp.ll
mv ./lib/Support/CMakeFiles/LLVMSupport.dir/FoldingSet{,_Support}.cpp.ll
mv ./lib/Support/CMakeFiles/LLVMSupport.dir/Error{,_Support}.cpp.bc
mv ./lib/Support/CMakeFiles/LLVMSupport.dir/FoldingSet{,_Support}.cpp.bc

find ./ -iname "*.ll" > ll_files.list
find ./ -iname "*.bc" > bc_files.list
```

### Copy artefacts

```
mkdir -p artefacts/bc
mkdir -p artefacts/ll

cd build
bash
while read -r line; do cp $line .././artefacts/bc; done < ./bc_files.list
while read -r line; do cp $line .././artefacts/ll; done < ./ll_files.list
```

