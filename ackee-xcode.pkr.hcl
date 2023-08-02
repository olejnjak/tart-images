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
  vm_base_name = "ghcr.io/olejnjak/xcode:${var.xcode_version}"
  vm_name      = "ackee-xcode:${var.xcode_version}"
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "120s"
  headless     = true
  disk_size_gb = 50
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
        "source ~/.zprofile",
        "curl -Ls https://install.tuist.io | bash",
        "mint install olejnjak/Torino",
        "mint install realm/SwiftLint",
        "ln -s '/Volumes/My Shared Files/ssh' ~/.ssh",
        "xcrun simctl create 'iPhone 13 Pro Max' 'iPhone 13 Pro Max'",
        "sudo systemsetup -settimezone Europe/Prague",
    ]
  }
}