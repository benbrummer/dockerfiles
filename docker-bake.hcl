variable "BASE" {
    default="benbrummer/invoiceninja-octane"
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
        "${BASE}:latest",
        "${BASE}:${VERSION}",
        "${BASE}:${MAJOR}",
        "${BASE}:${MINOR}"]
    target = "app"
}

target "scheduler" {
    description = "Laravel Scheduler for Invoiceninja Application Image"
    tags = [
        "${BASE}-scheduler:latest",
        "${BASE}-scheduler:${VERSION}",
        "${BASE}-scheduler:${MAJOR}",
        "${BASE}-scheduler:${MINOR}"]
    target = "scheduler"
}

target "worker" {
    description = "Laravel Worker for Invoiceninja Application Image"
    tags = [
        "${BASE}-worker:latest",
        "${BASE}-worker:${VERSION}",
        "${BASE}-worker:${MAJOR}",
        "${BASE}-worker:${MINOR}"
        ]
    target = "worker"
}
