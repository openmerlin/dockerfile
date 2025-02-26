variable "registry" {
  default = []
}
variable "cann" {
  default = []
}
variable "python" {
  default = []
}
variable "pytorch" {
  default = []
}
variable "mindspore" {
  default = []
}

function "generate_tags" {
  params = [repo, tags]
  result = flatten([
    for reg in registry : [
      for tag in tags : [
        "${reg.url}/${reg.owner}/${repo}:${tag}"
      ]
    ]
  ])
}

group "default" {
  targets = ["cann", "python", "pytorch", "mindspore"]
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
}

target "base-target" {
  inherits = ["docker-metadata-action"]
  platforms = ["linux/amd64", "linux/arm64"]
}

target "cann" {
  inherits = ["base-target"]
  name = replace("cann-${item.tags[0]}", ".", "_")
  context = "cann"
  dockerfile = "${item.os_name}.Dockerfile"
  matrix = {
    item = cann
  }
  args = {
    BASE_VERSION = "${item.os_version}"
    PY_VERSION = "${item.py_version}"
    CANN_CHIP = "${item.cann_chip}"
    CANN_VERSION = "${item.cann_version}"
  }
  tags = generate_tags("cann", "${item.tags}")
}

