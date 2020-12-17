# Fast builds for repositories using php-actions.

v1 of this repository used a totally different architecture and had different goals to the current version. Previously, a customised Dockerfile was used as the base for all php-actions repositories, but now php-actions workflows run as [composite run steps][composite], building a customised docker image per-application, based off the official PHP script.

The bash script within this repository is run as [composite run steps][composite] in [php-actions repositories][php-actions]. It builds a minimal docker image for running each particular php-action job and pushes the built image as a package, stored on the repository that is using the action.

You do not need to know the following information if you want to use a php-actions Github Action within your own repository - only if you are planning on contributing to the php-actions base Docker image.

Environment variables
---------------------

The following environment variables must be passed to the composite run step:

+ `GITHUB_ACTOR` - The name of the person or app that initiated the workflow, for example: `g105b`. This user will be used to authenticate the pull/push of the Docker image.
+ `GITHUB_REPOSITORY` - The owner and repository name of the repository running the action, for example: `phpgt/database`. This is where the built image will be pushed to as a package.
+ `ACTION_TOKEN` - The Github PAT used to authenticate the `docker login` step. This is probably taken directly from the `github.token` secret, which is generated automatically by the action runner.
+ `ACTION_PHP_VERSION` - The semver version number string of the required PHP version to use.

The following environment variables are optionally passed to the composite run step:

+ `ACTION_PHP_EXTENSIONS` - A space-separated list of extensions to enable.

Choosing the PHP version
------------------------

The `ACTION_PHP_VERSION` environment variable must be passed to the composite run step. This string must match any of the [officially supported PHP version numbers][tag-list] (version number only, with no derivative text, e.g. `8.0.1` or `8` rather than `8-cli`).

The official Alpine CLI build of the requested version will be used as the image's base. 

Enabling/disabling extensions
-----------------------------

The `ACTION_PHP_EXTENSIONS` environment variable can be passed to the composite run step. This string must be a space separated list of all extension names required by the running action's repository. The names of the extensions may also include a version number to use.

For example: `gd xdebug-2.9.7 zip`.

The functionality of building PHP extensions is provided by [mlocati's docker-php-extension-installer repository][mlocati]. A full list of supported extension names is [available within the readme][mlocati-readme].

Using the docker tag from subsequent scripts
--------------------------------------------

Once the Docker image is built and tagged, the name of the tag will be written to a file called `docker-tag` within the current working directory. This can then be read by a subsequent script.

***

If you found this repository helpful, please consider [sponsoring the developer][sponsor].

[composite]: https://github.blog/changelog/2020-08-07-github-actions-composite-run-steps/
[php-actions]: https://github.com/php-actions
[tag-list]: https://github.com/docker-library/docs/blob/master/php/README.md#supported-tags-and-respective-dockerfile-links
[mlocati]: https://github.com/mlocati/docker-php-extension-installer
[mlocati-readme]: https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions
[issues]: https://github.com/php-actions/php-build/issues
[sponsor]: https://github.com/sponsors/g105b