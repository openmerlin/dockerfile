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
      contains(keys(tags), reg.name) ? [
        for tag in tags[reg.name] : [
          "${reg.url}/${reg.owner}/${repo}:${tag}"
        ]
      ]
      : [
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
  name = replace("cann-${item.tags.common[0]}", ".", "_")
  context = "cann"
  dockerfile = "${item.tags.common[0]}.Dockerfile"
  matrix = {
    item = cann
  }
  tags = generate_tags("cann", "${item.tags}")
}

target "python" {
  inherits = ["base-target"]
  name = replace("python-${item.tags.common[0]}", ".", "_")
  context = "python"
  dockerfile = "${item.tags.common[0]}.Dockerfile"
  matrix = {
    item = python
  }
  tags = generate_tags("python", "${item.tags}")
}

target "pytorch" {
  inherits = ["base-target"]
  name = replace("pytorch-${item.tags.common[0]}", ".", "_")
  context = "pytorch"
  dockerfile = "${item.tags.common[0]}.Dockerfile"
  matrix = {
    item = pytorch
  }
  tags = generate_tags("pytorch", "${item.tags}")
}

target "mindspore" {
  inherits = ["base-target"]
  name = replace("mindspore-${item.tags.common[0]}", ".", "_")
  context = "mindspore"
  dockerfile = "${item.tags.common[0]}.Dockerfile"
  matrix = {
    item = mindspore
  }
  tags = generate_tags("mindspore", "${item.tags}")
}
