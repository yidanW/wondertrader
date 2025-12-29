if [ ! -d "./build_debug" ];then
mkdir build_debug
fi
cd build_debug
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-Wno-error -Wno-nonnull -Wno-deprecated-declarations" ..
make -j8