# Release Tag and Repository
if [ "$TRAVIS_BRANCH" = "master" ]; then
    if ! [ "$TRAVIS_EVENT_TYPE" = "pull_request" ]; then
        ARTIFACTORY_REPO=hyc-cloud-private-integration-helm-local
        VERSION=99.99.99
        export VERSION_NUMBER="$VERSION"
        export ARTIFACTORY_REPO="$ARTIFACTORY_REPO"
    fi
fi

echo ARTIFACTORY_REPO=$ARTIFACTORY_REPO
echo VERSION=$VERSION_NUMBER
