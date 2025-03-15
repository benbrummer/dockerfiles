variable "IMAGE_NAME" {
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
        INVOICENINJA_VERSION = "${VERSION}"
    }
    platforms = ["linux/amd64", "linux/arm64"]
    pull = true
}

target "app" {
    description = "Invoiceninja Application Image"
    inherits = ["_common"]
    tags = [
        "${IMAGE_NAME}:latest-octane",
        "${IMAGE_NAME}:${VERSION}-octane",
        "${IMAGE_NAME}:${MAJOR}-octane",
        "${IMAGE_NAME}:${MINOR}-octane"]
    target = "app"
}

target "scheduler" {
    description = "Laravel Scheduler for Invoiceninja Application Image"
    tags = [
        "${IMAGE_NAME}:latest-octane-scheduler",
        "${IMAGE_NAME}:${VERSION}-octane-scheduler",
        "${IMAGE_NAME}:${MAJOR}-octane-scheduler",
        "${IMAGE_NAME}:${MINOR}-octane-scheduler"]
    target = "scheduler"
}

target "worker" {
    description = "Laravel Worker for Invoiceninja Application Image"
    tags = [
        "${IMAGE_NAME}:latest-octane-worker",
        "${IMAGE_NAME}:${VERSION}-octane-worker",
        "${IMAGE_NAME}:${MAJOR}-octane-worker",
        "${IMAGE_NAME}:${MINOR}-octane-worker"
        ]
    target = "worker"
}
