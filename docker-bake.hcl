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
      if contains(keys(tags), reg.name) : [
        for tag in tags[reg.name] : [
          "${reg.url}/${reg.owner}/${repo}:${tag}"
        ]
      ] 
      else : [
        for tag in tags["common"] : [
          "${reg.url}/${reg.owner}/${repo}:${tag}"
        ]
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

target "python" {
  inherits = ["base-target"]
  name = replace("python-${item.tags[0]}", ".", "_")
  context = "python"
  dockerfile = "${item.os_name}.Dockerfile"
  matrix = {
    item = python
  }
  args = {
    BASE_VERSION = "${item.os_version}"
    PY_VERSION = "${item.py_version}"
  }
  tags = generate_tags("python", "${item.tags}")
}

target "pytorch" {
  inherits = ["base-target"]
  name = replace("pytorch-${item.tags[0]}", ".", "_")
  context = "pytorch"
  dockerfile = "Dockerfile"
  matrix = {
    item = pytorch
  }
  args = {
    BASE_VERSION = "${item.cann_tag}"
    PYTORCH_VERSION = "${item.pytorch_version}"
  }
  tags = generate_tags("pytorch", "${item.tags}")
}

target "mindspore" {
  inherits = ["base-target"]
  name = replace("mindspore-${item.tags[0]}", ".", "_")
  context = "mindspore"
  dockerfile = "Dockerfile"
  matrix = {
    item = mindspore
  }
  args = {
    BASE_VERSION = "${item.cann_tag}"
    MINDSPORE_VERSION = "${item.mindspore_version}"
  }
  tags = generate_tags("mindspore", "${item.tags}")
}
