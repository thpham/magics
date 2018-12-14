gofmt:
	gofmt -w -s pkg/ cmd/

gazelle:
	bazel run //:gazelle

run:
	bazel run //cmd/cli:bin

run-server:
	bazel run //cmd/cli:bin

images:
	bazel run --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 --define CORTEX_TAG=latest //:images

push:
	bazel run --define CORTEX_TAG=latest //:images.push
