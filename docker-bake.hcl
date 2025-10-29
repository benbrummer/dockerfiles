variable "REGISTRY_IMAGE" {
    default="benbrummer/invoiceninja"
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
      "app",
      "scheduler",
      "worker"
    ]
}

target _common {
    args = {
        URL = "https://github.com/invoiceninja/invoiceninja/releases/latest/download/invoiceninja.tar.gz"
    }
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
    tags = [        
        "${REGISTRY_IMAGE}:${VERSION}-octane",
        "${REGISTRY_IMAGE}:${MAJOR}-octane",
        "${REGISTRY_IMAGE}:${MINOR}-octane",
        "${REGISTRY_IMAGE}:latest-octane"
    ]
    pull = true
}

target "app" {
    description = "Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [for tag in target._common.tags : replace(tag, "octane", "octane-app")]
}

target "scheduler" {
    description = "Laravel Scheduler for Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [for tag in target._common.tags : replace(tag, "octane", "octane-scheduler")]
    target = "scheduler"
}

target "worker" {
    description = "Laravel Worker for Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [for tag in target._common.tags : replace(tag, "octane", "octane-worker")]
    target = "worker"
}
