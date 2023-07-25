packer {
  required_plugins {
    tart = {
      version = ">= 1.2.0"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "xcode_version" {
  type = string
}

source "tart-cli" "tart" {
  vm_base_name = "ghcr.io/olejnjak/ventura-base:latest"
  vm_name      = "xcode:${var.xcode_version}"
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 40
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
  headless     = true
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
        "echo 'export PATH=/usr/local/bin/:$PATH' >> ~/.zprofile",
        "source ~/.zprofile",
        "brew install xcodesorg/made/xcodes",
        "echo 'Downloading Xcode'",
        "wget --quiet https://storage.googleapis.com/xcodes-cache/Xcode_${var.xcode_version}.xip",
        "echo 'Downloaded Xcode'",
        "echo 'Starting Xcode installation'",
        "xcodes install ${var.xcode_version} --experimental-unxip --path $PWD/Xcode_${var.xcode_version}.xip",
        "echo 'Xcode installed'",
        "sudo rm -rf ~/.Trash/*",
        "xcodes select ${var.xcode_version}",
        "xcodebuild -downloadPlatform ios",
        "xcodebuild -runFirstLaunch",
    ]
  }

  provisioner "shell" {
    inline = [
        "source ~/.zprofile",
        "brew install carthage imagemagick",
    ]
  }
}