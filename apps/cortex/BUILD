# layer targets:cortex
load("@bazel_gazelle//:def.bzl", "gazelle")
gazelle(
    name = "gazelle",
    command = "fix",
    prefix = "github.com/thpham/cortex",
)

# build docker images
load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_image",
    "container_bundle",
)
container_image(
    name = "server-image",
    base = "@go_image_base//image",
    entrypoint = ["/usr/bin/cortex"],
    cmd = ["serve"],
    directory = "/usr/bin/",
    files = [
        "//cmd/cli:bin-linux",
    ],
    creation_time = "{BUILD_TIMESTAMP}",
    stamp = True,
)
container_bundle(
    name = "images",
    images = {
        "ithings/cortex:$(CORTEX_TAG)": "server-image",
    },
)

load("@io_bazel_rules_docker//contrib:push-all.bzl", "docker_push")
docker_push(
    name = "images.push",
    bundle = ":images",
)