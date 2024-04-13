FROM paddlepaddle/paddle:2.6.1-gpu-cuda11.2-cudnn8.2-trt8.0

ARG compile=false

RUN python3 --version
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qqy install libcurl4-openssl-dev libbz2-dev
# && DEBIAN_FRONTEND=noninteractive apt-get -qqy install python3-pip ffmpeg git less nano libsm6 libxext6 libxrender-dev \
# && rm -rf /var/lib/apt/lists/*

# Install Go and glide
RUN rm -rvf /usr/local/go/
RUN wget --no-check-certificate -qO- https://go.dev/dl/go1.19.13.linux-amd64.tar.gz | tar -xz -C /usr/local
ENV GOROOT=/usr/local/go GOPATH=${HOME}/go
# should not be in the same line with GOROOT definition, otherwise docker build could not find GOROOT.
ENV PATH=${PATH}:${GOROOT}/bin:${GOPATH}/bin
# install glide
RUN EBIAN_FRONTEND=noninteractive apt-get install -y golang-glide

ENV PYTHON_INCLUDE_DIR=/usr/include/python3.10/
ENV PYTHON_LIBRARIES=/usr/lib/x86_64-linux-gnu/libpython3.10.so
ENV PYTHON_EXECUTABLE=/usr/bin/python3.10

ENV CUDA_PATH='/usr/local/cuda'
ENV CUDNN_LIBRARY='/usr/local/cuda/lib64/'
ENV CUDA_CUDART_LIBRARY="/usr/local/cuda/lib64/"
ENV TENSORRT_LIBRARY_PATH="/usr/"

COPY . /app/
WORKDIR /app

#RUN bash tools/paddle_env_install.sh
RUN pip3 install --upgrade pip
RUN pip3 install -r python/requirements.txt
#RUN pip3 install paddle-serving-client==0.9.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
#RUN pip3 install paddle-serving-app==0.9.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
#RUN pip3 install paddle-serving-server-gpu==0.9.0.post112 -i https://pypi.tuna.tsinghua.edu.cn/simple

RUN go env -w GO111MODULE=on
#RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v1.15.2
RUN go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@v1.15.2
RUN go install github.com/golang/protobuf/protoc-gen-go@v1.4.3
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
RUN go env -w GO111MODULE=auto

WORKDIR /app
# Enable compile these
RUN bash tools/dockerfiles/build_scripts/compile.sh
RUN pip3.10 install whl-compile/*.whl

#RUN pip3 install \
#  git+https://github.com/1adrianb/face-alignment \
#  -r requirements.txt
#RUN pip3 install opencv-fixer==0.2.5
#RUN python3 -c "from opencv_fixer import AutoFix; AutoFix()"