# Choose between PHP versions and installed extensions in your Github Actions.

This is a base image used by all php-actions repositories. It contains all compiled versions of PHP that are currently supported:

* 8.0
* 7.4 **(latest)**
* 7.3
* 7.2
* 7.1

The default version to be put on the PATH is `latest`. To change the version of PHP that is on the path, use the `switch-php-version- and pass the version number as the only argument. For example, to switch to PHP version 8.0:

```bash
switch-php-version 8.0
```

The following extensions are enabled by default:

* libxml
* curl
* zip
* mysqli
* pdo-mysql
* bcmath
* gd
* intl
* mbstring

If you require any other extensions, please [open an issue][issues] and, if possible, describe the way in which the extension should be compiled.

Known limitations
-----------------

### Speed

Currently the image is based off `ubuntu:latest`, to match the base image that many Github Actions use. Then there are multiple versions of PHP compiled within the image, which creates a larger base image than usual. This can cause Github Actions to run slowly, as for some reason some workflows insist on ignoring any caching of image layers. If you know how to improve the speed, please [let us know in the issue tracker][issues]. 

### Enabling/disabling extensions

The list of extensions above are enabled by default, but it might be an improvement to only enable extensions that are required, by adjusting the php.ini file on-the-fly. This is just an idea for now, but if it sounds like it would be an improvement, please let us know your suggestions [in the issue tracker][issues].

Supporting future development
-----------------------------

If you found this repository helpful, please consider [sponsoring the developer][sponsor].

[issues]: https://github.com/php-actions/php-build/issues
[sponsor]: https://github.com/sponsors/g105b