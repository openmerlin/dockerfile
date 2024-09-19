# Python Docker Image

We provide multiple python versions built from source. Each image contains the minimum set of dependencies
required by the python runtime, as follows:

- `bash`
- `glibc`
- `sqlite`
- `python`
- `pip`

Here are available tags and the build args can be found at [arg.json](../arg.json).

- `3.8`
- `3.9`
- `3.10`

> [!NOTE]
>
> If your desired tag is not here, feel free to file an issue with us or
> try to build it yourself.

## Usage

```docker
docker run --rm -it ascendai/python:3.10-ubuntu22.04 \
    python -c "import sys; print(sys.version)"
```

## Build

If you have Docker Engine 20.10+, then you can use Bake to build Docker images. Run the following command
in the root directory:

```docker
docker buildx bake -f arg.json -f docker-bake.hcl python
```

Don't have Bake? Use `docker build` instead. It requires Docker Engine 18+. Run the following command
in the root directory:

```docker
docker build \
    -t ascendai/python:3.10-ubuntu22.04 \
    -f python/ubuntu.Dockerfile \
    --build-arg BASE_VERSION=22.04 \
    --build-arg PY_VERSION=3.10 \
    python/
```
