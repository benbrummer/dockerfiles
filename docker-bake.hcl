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
    tags = ["invoiceninja/invoiceninja-octane:latest"]
    target = "app"
}

target "scheduler" {
    description = "Laravel Scheduler for Invoiceninja Application Image"
    tags = ["invoiceninja/invoiceninja-octane-scheduler:latest"]
    target = "scheduler"
}

target "worker" {
    description = "Laravel Worker for Invoiceninja Application Image"
    tags = ["invoiceninja/invoiceninja-octane-worker:latest"]
    target = "worker"
}
