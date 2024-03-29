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
        "/usr/sbin/softwareupdate --install-rosetta --agree-to-license",
    ]
  }

  provisioner "shell" {
    inline = [
        "source ~/.zprofile",
        "brew install carthage unzip zip ca-certificates",
    ]
  }

  # inspired by https://github.com/actions/runner-images/blob/fb3b6fd69957772c1596848e2daaec69eabca1bb/images/macos/provision/configuration/configure-machine.sh#L33-L61
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "sudo security delete-certificate -Z FF6797793A3CD798DC5B2ABEF56F73EDC9F83A64 /Library/Keychains/System.keychain",
      "sudo mkdir -p /usr/local/bin/",
      "curl -o add-certificate.swift https://raw.githubusercontent.com/actions/runner-images/fb3b6fd69957772c1596848e2daaec69eabca1bb/images/macos/provision/configuration/add-certificate.swift",
      "swiftc add-certificate.swift",
      "sudo mv ./add-certificate /usr/local/bin/add-certificate",
      "curl -o AppleWWDRCAG3.cer https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer",
      "curl -o DeveloperIDG2CA.cer https://www.apple.com/certificateauthority/DeveloperIDG2CA.cer",
      "sudo add-certificate AppleWWDRCAG3.cer",
      "sudo add-certificate DeveloperIDG2CA.cer",
      "rm add-certificate* *.cer"
    ]
  }
}