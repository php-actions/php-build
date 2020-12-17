#!/bin/bash
set -e

# Check for required variables:
if [ "$#" -lt 1 ]; then
    echo "Must pass argument 1: the name of the action currently running"
    exit 1
fi
echo "Running php-build $1"

if [ -z "$GITHUB_ACTOR" ]
then
	echo "Error: GITHUB_ACTOR variable not set"
	exit 1
fi

if [ -z "$GITHUB_REPOSITORY" ]
then
	echo "Error: GITHUB_REPOSITORY variable not set"
	exit 1
fi

if [ -z "$ACTION_TOKEN" ]
then
	echo "Error: ACTION_TOKEN variable not set"
	exit 1
fi

if [ -z "$ACTION_PHP_VERSION" ]
then
	echo "Error: ACTION_PHP_VERSION variable not set"
	exit 1
fi

# The dockerfile is created in-memory and written to disk at the end of this script.
# Below, depending on the Action's inputs, more lines may be written to this dockerfile.
# Zip and git are required for Composer to work correctly.
base_image="php:"
if [ "$ACTION_PHP_VERSION" != "latest" ]
then
	base_image="${base_image}-${ACTION_PHP_VERSION}-"
fi
base_image="${base_image}cli-alpine"
dockerfile="FROM ${base_image}
RUN apk add --update --no-cache zip git bash"

base_repo="$1"

# We log into the Github docker repository on behalf of the user that is
# running the action (this could be anyone, outside of the php-actions organisation).
echo "${ACTION_TOKEN}" | docker login docker.pkg.github.com -u "${GITHUB_ACTOR}" --password-stdin

# If there are any extensions to be installed, we do this using the
# install-php-extensions tool. If there are not extensions required, we don't
# need to install this tool at all.
if [ -n "$ACTION_PHP_EXTENSIONS" ]
then
	dockerfile="${dockerfile}
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/"
	dockerfile="${dockerfile}
RUN chmod +x /usr/local/bin/install-php-extensions && sync && install-php-extensions"
fi

# For each extension installed, we add the name to the end of the
# dockerfile_unique variable, which is used to tag the Docker image.
dockerfile_unique="php-${ACTION_PHP_VERSION}"
for ext in $ACTION_PHP_EXTENSIONS
do
	dockerfile="${dockerfile} $ext"
	dockerfile_unique="${dockerfile_unique}-${ext}"
done

# Remove illegal characters and make lowercase:
GITHUB_REPOSITORY="${GITHUB_REPOSITORY,,}"
dockerfile_unique="${dockerfile_unique// /_}"
dockerfile_unique="${dockerfile_unique,,}"

# This tag will be used to identify the built dockerfile. Once it is built,
# it should not need to be built again, so after the first Github Actions run
# the build should be very quick.
# Note: The GITHUB_REPOSITORY is the repo where the action is running, nothing
# to do with the php-actions organisation. This means that the image is pushed
# onto a user's Github profile (currently not shared between other users).
docker_tag="docker.pkg.github.com/${GITHUB_REPOSITORY}/php-actions_${base_repo}:${dockerfile_unique}"
echo "$docker_tag" > ./docker_tag

# Attempt to pull the existing Docker image, if it exists. If the image has
# been pushed previously, this image should take preference and a new image
# will not need to be built.
echo "Pulling $docker_tag"

# No need to continue building the image if the pull was successful.
if docker pull "$docker_tag";
then
	exit
fi

# Save the dockerfile to a physical file on disk, then build the image, tagging
# it with the unique tag. If the layers are already built, there should be no
# need to re-build, and the `docker build` step should use the cached layers of
# what has just been pulled.
echo "$dockerfile" > Dockerfile
echo "Dockerfile:"
echo "$dockerfile"
docker build --tag "$docker_tag" --cache-from "$docker_tag" .
# Update the user's repository with the customised docker image, ready for the
# next Github Actions run.
docker push "$docker_tag"
