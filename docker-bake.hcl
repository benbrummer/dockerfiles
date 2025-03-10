variable "BASE" {
    default="invoiceninja/invoiceninja-octane"
}
variable "VERSION" {
    default="latest"
}

variable "MAJOR" {
    default="latest"
}

variable "MAJOR_MINOR" {
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
        "${BASE}:${MAJOR_MINOR}"]
    target = "app"
}

target "scheduler" {
    description = "Laravel Scheduler for Invoiceninja Application Image"
    tags = [
        "${BASE}-scheduler:latest",
        "${BASE}-scheduler:${VERSION}",
        "${BASE}-scheduler:${MAJOR}",
        "${BASE}-scheduler:${MAJOR_MINOR}"]
    target = "scheduler"
}

target "worker" {
    description = "Laravel Worker for Invoiceninja Application Image"
    tags = [
        "${BASE}-worker:latest",
        "${BASE}-worker:${VERSION}",
        "${BASE}-worker:${MAJOR}",
        "${BASE}-worker:${MAJOR_MINOR}"
        ]
    target = "worker"
}
