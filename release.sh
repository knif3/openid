#!/bin/sh

set -e

# Check that we are on the master branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "Error: release.sh must be run on the master branch"
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

RELEASE_TYPE=${RELEASE_TYPE:-minor}

if [ "${RELEASE_TYPE}" != "current" ]; then
  cargo set-version --bump ${RELEASE_TYPE}
fi
VERSION=`cargo pkgid | cut -d"#" -f2`
export CRATE="openid"
export CRATE_RUST_MAJOR_VERSION=`echo ${VERSION} | cut -d"." -f1,2`
if [[ "${RELEASE_TYPE}" != "patch" && "${RELEASE_TYPE}" != "current" ]]; then
    pushd ../${CRATE}-examples
    git checkout main
    git pull
    cargo upgrade -p ${CRATE}@${CRATE_RUST_MAJOR_VERSION}
    cargo update
    cargo build
    git add .
    git commit -m"${CRATE} version ${CRATE_RUST_MAJOR_VERSION}"
    git branch v${CRATE_RUST_MAJOR_VERSION}
    git push
    git push origin v${CRATE_RUST_MAJOR_VERSION}
    popd
fi
handlebars-magic templates .
git add .
git commit -m"Release ${VERSION}"
git tag v${VERSION}
git push && git push --tag