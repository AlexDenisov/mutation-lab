### Get compilation_database.json

```
mkdir build
cd build
cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DLLVM_TARGETS_TO_BUILD="X86" ../llvm
cd ..
cp build/compile_commands.json ./
```

