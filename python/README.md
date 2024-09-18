# Python Docker Image

## Usage

```docker
docker run --rm -it ascendai/python:3.10-ubuntu22.04 \
    python -c "import sys; print(sys.version)"
```

## Build

If you have Docker Engine 20.10+, then you can use Bake to build Docker images:

```docker
docker buildx bake -f arg.json -f docker-bake.hcl python
```

Don't have Bake? Use `docker build` instead. It requires Docker Engine 18+.

```docker
docker build \
    -t ascendai/python:3.10-ubuntu22.04 \
    -f python/ubuntu.Dockerfile \
    --build-arg BASE_VERSION=22.04 \
    --build-arg PY_VERSION=3.10 \
    python/
```
