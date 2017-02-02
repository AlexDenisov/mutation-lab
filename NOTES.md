## Taking notes while experimenting

All commands start at root directory.

Artefacts are compressed to save some space (~150MB vs ~1GB)

### Get compilation database just for one target

```
mkdir build
cd build
cmake -G Ninja -DLLVM_TARGETS_TO_BUILD="X86" ../llvm

ninja -t compdb (grep -o '\S*COMPILER__ADTTests' rules.ninja)
# Posix shells
ninja -t compdb `grep -o '\S*COMPILER__ADTTests' rules.ninja`
```

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

ninja -t commands IRTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.bc/' \
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

### Running mutang-driver on gtest mode

Find this code in `driver.cpp`

```
#if 0
  GoogleTestFinder TestFinder;
  GoogleTestRunner Runner;
#else
  SimpleTestFinder TestFinder;
  SimpleTestRunner Runner;
#endif
```

Replace 0 with 1, re-build and run against local_config.yaml

```
time ./Debug/bin/mutang-driver path/to/local_config.yaml
```

The debug version will take lots of time so it's recommended to build the driver in Release configuration.

## Local Setup

```
mkdir -p /usr/local/LLVM
mkdir -p /usr/local/LLVM/build
mkdir -p /usr/local/LLVM/mull_cache
cd /usr/local/LLVM
git clone http://llvm.org/git/llvm.git
cd llvm && git checkout 62cfc59ef6c196a7d60e2e56d64d6aa63a2466ce
cd ../build
cmake -G Ninja -DLLVM_TARGETS_TO_BUILD="X86" ../llvm/
ninja llvm-tblgen
ninja -t commands IRTests | grep -v "^:" | sed -e 's/\(-o .*\)\.o/\1.bc/' \
    -e 's/\(\/App.*\)$/\1 -emit-llvm -DNDEBUG/' \
    -e 's|/Applications/.*/c++|/usr/local/opt/llvm/bin/clang++|' \
    > ir_tests_commands.sh
```

Now you need to open `ir_tests_commands.sh`, find each command that starts with `cd` and add `cd -` to the next line. It should look like this:

```sh
cd /usr/local/LLVM/IRTests/include/llvm/IR && /usr/local/LLVM/IRTests/bin/llvm-tblgen -gen-attrs -I /usr/local/LLVM/llvm/include/llvm/IR -I /usr/local/LLVM/llvm/lib/Target -I /usr/local/LLVM/llvm/include /usr/local/LLVM/llvm/include/llvm/IR/Attributes.td -o /usr/local/LLVM/IRTests/include/llvm/IR/Attributes.gen.tmp
cd -
```

Now proceed with the following:

```
sh ir_tests_commands_ll.sh
echo "fork: true" > config.yaml
echo "max_distance: 2" >> config.yaml
echo "dry_run: false" >> config.yaml
echo "cache_directory: /usr/local/LLVM/mull_cache" >> config.yaml
echo "" >> config.yaml
echo "bitcode_files:" >> config.yaml
find `pwd` -name "*.bc" | sed 's/\(.*\)/  - \1/' >> config.yaml
```
And then just run `mull-driver` against `/usr/local/LLVM/IRTests/config.yaml`


