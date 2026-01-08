variable "REGISTRY_IMAGE" {
    default="benbrummer/invoiceninja"
}

variable "URL" {
    default = "https://github.com/invoiceninja/invoiceninja/releases/latest/download/invoiceninja.tar.gz"
}

variable "VERSION" {
    default="latest"
}

variable "MAJOR" {
    default="latest"
}

variable "MINOR" {
    default="latest"
}

group "default" {
    targets = [
      "aio",
      "app",
      "scheduler",
      "worker"
    ]
}

target _common {
    args = {
        URL = "${URL}"
    }
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
    tags = [        
        "${REGISTRY_IMAGE}:${VERSION}-",
        "${REGISTRY_IMAGE}:${MAJOR}-",
        "${REGISTRY_IMAGE}:${MINOR}-",
        "${REGISTRY_IMAGE}:latest-"
    ]
    pull = true
}

target "aio" {
    description = "AIO for Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [for tag in target._common.tags : replace(tag, "-", "-aio")]
    target = "aio"
}

target "app" {
    description = "Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [for tag in target._common.tags : replace(tag, "-", "-app")]
    target = "app"
}

target "scheduler" {
    description = "Laravel Scheduler for Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [for tag in target._common.tags : replace(tag, "-", "-scheduler")]
    target = "scheduler"
}

target "worker" {
    description = "Laravel Worker for Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [for tag in target._common.tags : replace(tag, "-", "-worker")]
    target = "worker"
}
