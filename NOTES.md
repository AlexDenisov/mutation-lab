## Taking notes while experimenting

All commands start at root directory.

Artefacts are compressed to save some space (~150MB vs ~1GB)

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

### Patch commands

Fixing name (.o -> .ll | .bc)
Replacing compiler with custom one
Adding required flags ([-S] -emit-llvm)

```
ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.ll/' \
                                              -e 's/\(\/App.*\)$/\1 -S -emit-llvm/' \
                                              -e 's|/Applications/.*/c++|/opt/clang/bin/clang++|'

ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.bc/' \
                                              -e 's/\(\/App.*\)$/\1 -emit-llvm/' \
                                              -e 's|/Applications/.*/c++|/opt/clang/bin/clang++|'
```

### Evaluate patched commands (human readable LLVM IR)

```
mkdir -p unittests/ADT/CMakeFiles/ADTTests.dir
ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.ll/' \
                                              -e 's/\(\/App.*\)$/\1 -S -emit-llvm/' \
                                              -e 's|/Applications/.*/c++|/opt/clang/bin/clang++|' \
                                              > commands_ll.sh
sh commands_ll.sh
```

### Evaluate patched commands (bitcode)

```
mkdir -p unittests/ADT/CMakeFiles/ADTTests.dir
ninja -t commands ADTTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.bc/' \
                                              -e 's/\(\/App.*\)$/\1 -emit-llvm/' \
                                              -e 's|/Applications/.*/c++|/opt/clang/bin/clang++|' \
                                              > commands_bc.sh
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

### Making config

```
echo "bitcode_files:" > config.yaml
ls artefacts/bc/ | sed 's/\(.*\)/  - artefacts\/bc\/\1/' >> config.yaml
```

### Making machine dependent config

http://stackoverflow.com/a/584926/829116

```
echo "bitcode_files:" > local_config.yaml
ls artefacts/bc/ | sed 's@\(.*\)@  - '"$PWD"'/artefacts/bc/\1@' >> local_config.yaml
```

### Build and install custom Clang

```
cmake -G Ninja -DBUILD_SHARED_LIBS=true -DLLVM_TARGETS_TO_BUILD="X86" -DCMAKE_INSTALL_PREFIX=/opt/clang ../llvm
cmake --build . --target install
```

