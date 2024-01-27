#!/bin/bash
set -euxo pipefail

HELLO_SOURCE_URL="https://github.com/${GITHUB_REPOSITORY:-rgl/spin-http-ts-example}.git"
if [[ "${GITHUB_REF:-v0.0.0-dev}" =~ \/v([0-9]+(\.[0-9]+)+(-.+)?) ]]; then
  HELLO_VERSION="${BASH_REMATCH[1]}"
else
  HELLO_VERSION='0.0.0-dev'
fi
HELLO_REVISION="${GITHUB_SHA:-0000000000000000000000000000000000000000}"

function dependencies {
  npm ci
}

function build {
  sed -i -E "s,( sourceUrl = ).+,\1\"$HELLO_SOURCE_URL\";,g" src/meta.ts
  sed -i -E "s,( version = ).+,\1\"$HELLO_VERSION\";,g" src/meta.ts
  sed -i -E "s,( revision = ).+,\1\"$HELLO_REVISION\";,g" src/meta.ts
  spin build
  sed -E 's,/?target/,,g' spin.toml >target/spin.toml
}

function release {
  local image="ghcr.io/$GITHUB_REPOSITORY:$HELLO_VERSION"

  # publish the application as a container image or as an oci image artifact.
  if false; then
    docker build \
      --build-arg "HELLO_SOURCE_URL=$HELLO_SOURCE_URL" \
      --build-arg "HELLO_VERSION=$HELLO_VERSION" \
      --build-arg "HELLO_REVISION=$HELLO_REVISION" \
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
