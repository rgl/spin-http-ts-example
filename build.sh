#!/bin/bash
set -euxo pipefail

function dependencies {
  npm ci
}

function build {
  spin build
  sed -E 's,/?target/,,g' spin.toml >target/spin.toml
}

function release {
  local hello_source_url="https://github.com/$GITHUB_REPOSITORY"

  if [[ "$GITHUB_REF" =~ \/v([0-9]+(\.[0-9]+)+(-.+)?) ]]; then
    local hello_version="${BASH_REMATCH[1]}"
  else
    echo "ERROR: Unable to extract semver version from GITHUB_REF."
    exit 1
  fi

  local hello_revision="$GITHUB_SHA"

  local image="ghcr.io/$GITHUB_REPOSITORY:$hello_version"

  # publish the application as a container image or as an oci image artifact.
  if false; then
    docker build \
      --build-arg "HELLO_SOURCE_URL=$hello_source_url" \
      --build-arg "HELLO_VERSION=$hello_version" \
      --build-arg "HELLO_REVISION=$hello_revision" \
      -t "$image" \
      .
    docker push "$image"
  else
    # NB spin registry push will create an oci image artifact. thou, it does not
    #    seem to attach any metadata to the oci image artifact. we can see a
    #    warning about a missing description metadata when you click the latest
    #    package version at:
    #       https://github.com/rgl/spin-http-ts-example/pkgs/container/spin-http-ts-example
    #    TODO review this after https://github.com/fermyon/spin/issues/2236 is
    #         addressed.
    spin registry push "$image"
  fi

  # create the release binary artifact.
  rm -rf dist && install -d dist
  cp target/* dist/
  cd dist
  tar czf "$(basename "$GITHUB_REPOSITORY").tgz" *
  echo "sha256 $(sha256sum *.tgz)" >release-notes.md
  cd ..
}

function main {
  local command="$1"; shift
  case "$command" in
    dependencies)
      dependencies "$@"
      ;;
    build)
      build "$@"
      ;;
    release)
      release "$@"
      ;;
    *)
      echo "ERROR: Unknown command $command"
      exit 1
      ;;
  esac
}

main "$@"
