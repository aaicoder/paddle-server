mkdir /app/build_server
cd /app/build_server
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
    -DPYTHON_LIBRARIES=$PYTHON_LIBRARIES \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_PATH} \
    -DCUDNN_LIBRARY=${CUDNN_LIBRARY} \
    -DCUDA_CUDART_LIBRARY=${CUDA_CUDART_LIBRARY} \
    -DTENSORRT_ROOT=${TENSORRT_LIBRARY_PATH} \
    -DSERVER=ON \
    -DWITH_GPU=ON ..
git config --global --add safe.directory '*'
make -j20


mkdir /app/build_app
cd /app/build_app
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
    -DPYTHON_LIBRARIES=$PYTHON_LIBRARIES \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -DAPP=ON ..
git config --global --add safe.directory '*'
make -j10

mkdir /app/build_client
cd /app/build_client
cmake -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
    -DPYTHON_LIBRARIES=$PYTHON_LIBRARIES \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -DCLIENT=ON ..
git config --global --add safe.directory '*'
make -j10

cd /app
cp -r build_server/python/dist/* whl-compile/
cp -r build_app/python/dist/* whl-compile/
cp -r build_client/python/dist/* whl-compile/
cp ${PWD}/build_server/core/general-server/serving whl-compile/serving
export SERVING_BIN=${PWD}/whl-compile/serving
rm -rf /app/build_server /app/build_app /app/build_client