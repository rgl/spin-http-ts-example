#!/bin/bash
set -euxo pipefail

if [ ! -v CI ]; then
  GITHUB_REPOSITORY='rgl/spin-http-ts-example'
fi

HELLO_SOURCE_URL="https://github.com/${GITHUB_REPOSITORY:-rgl/spin-http-ts-example}"
if [[ "${GITHUB_REF:-v0.0.0-dev}" =~ \/v([0-9]+(\.[0-9]+)+(-.+)?) ]]; then
  HELLO_VERSION="${BASH_REMATCH[1]}"
else
  HELLO_VERSION='0.0.0-dev'
fi
HELLO_REVISION="${GITHUB_SHA:-0000000000000000000000000000000000000000}"
HELLO_DESCRIPTION="$(jq -r .description package.json)"
HELLO_LICENSE="$(jq -r .license package.json)"

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

  # publish the application as a docker container image or as an oci image artifact.
  if true; then
    docker build \
      --label "org.opencontainers.image.source=$HELLO_SOURCE_URL" \
      --label "org.opencontainers.image.version=$HELLO_VERSION" \
      --label "org.opencontainers.image.revision=$HELLO_REVISION" \
      --label "org.opencontainers.image.description=$HELLO_DESCRIPTION" \
      --label "org.opencontainers.image.licenses=$HELLO_LICENSE" \
      -t "$image" \
      .
    docker push "$image"
  else
    # TODO https://github.com/fermyon/spin/issues/2236.
    spin registry push \
      --annotation "org.opencontainers.image.source=$HELLO_SOURCE_URL" \
      --annotation "org.opencontainers.image.version=$HELLO_VERSION" \
      --annotation "org.opencontainers.image.revision=$HELLO_REVISION" \
      --annotation "org.opencontainers.image.description=$HELLO_DESCRIPTION" \
      --annotation "org.opencontainers.image.licenses=$HELLO_LICENSE" \
      "$image"
  fi

  # create the release binary artifact.
  rm -rf dist && install -d dist
  cp target/* dist/
  cd dist
  tar czf "$(basename "$HELLO_SOURCE_URL").tgz" *
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
