variable "BASE" {
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
        "${BASE}:latest-octane",
        "${BASE}:${VERSION}-octane",
        "${BASE}:${MAJOR}-octane",
        "${BASE}:${MINOR}-octane"]
    target = "app"
}

target "scheduler" {
    description = "Laravel Scheduler for Invoiceninja Application Image"
    tags = [
        "${BASE}:latest-octane-scheduler",
        "${BASE}:${VERSION}-octane-scheduler",
        "${BASE}:${MAJOR}-octane-scheduler",
        "${BASE}:${MINOR}-octane-scheduler"]
    target = "scheduler"
}

target "worker" {
    description = "Laravel Worker for Invoiceninja Application Image"
    tags = [
        "${BASE}:latest-octane-worker",
        "${BASE}:${VERSION}-octane-worker",
        "${BASE}:${MAJOR}-octane-worker",
        "${BASE}:${MINOR}-octane-worker"
        ]
    target = "worker"
}
