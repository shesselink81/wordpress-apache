// docker-bake.hcl
target "docker-metadata-action" {}

target "build" {
  inherits = ["docker-metadata-action"]
  context = "./"
  dockerfile = "Dockerfile"
  args = {
    WP_DOMAINNAME = "${WP_DOMAINNAME}"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
