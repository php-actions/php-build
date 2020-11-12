How to contribute to php-actions/php-build
==========================================

To build this image for local development:

```bash
docker build .
```

The last line from `docker build` will show the image ID, which identifies the final layer of the image. You can use this ID to interact further.

To launch into the image, within a bash shell:

```bash
docker run -it $image_id /bin/bash
```

After making changes, run `docker build .` again to build the extra layers that you've added, making a note of the new image ID.

```bash
docker tag $new_image_id ghcr.io/php-actions/php-build:$version_number
```

To deploy the version to Github:

```bash
docker push ghcr.io/php-actions/php-build:$version_number
```