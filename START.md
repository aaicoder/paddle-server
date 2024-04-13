

## Docker build image
```bash
docker build -t paddle-server .
```
## Docker run bash
```bash
docker run -p 9292:9292 -it --rm --gpus all --ulimit memlock=-1 -v $(pwd):/app paddle-server /bin/bash
```

## Run an example service
[快速开始](doc/Quick_Start_CN.md)