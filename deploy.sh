#!/bin/bash
set -e

DISTRIBUTION_ID=E14EZS8EVJ0AAY
BUCKET_NAME=blog-mywebofthings

export AWS_DEFAULT_REGION=eu-central-1

hugo -v 

mkdir -p public/{img,css,js}
mkdir -p static/downloads

# Copy over pages - not static js/img/css/downloads
aws s3 sync --storage-class "REDUCED_REDUNDANCY" --acl "public-read" --sse "AES256" public/ s3://$BUCKET_NAME/ --exclude 'img' --exclude 'js' --exclude 'downloads' --exclude 'css' --exclude 'post'

# Ensure static files are set to cache forever - cache for a month --cache-control "max-age=2592000"
aws s3 sync --storage-class "REDUCED_REDUNDANCY"  --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/img/ s3://$BUCKET_NAME/img/
aws s3 sync --storage-class "REDUCED_REDUNDANCY"  --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/css/ s3://$BUCKET_NAME/css/
aws s3 sync --storage-class "REDUCED_REDUNDANCY"  --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/js/ s3://$BUCKET_NAME/js/

# Downloads binaries, not part of repo - cache at edge for a year --cache-control "max-age=31536000"
aws s3 sync --storage-class "REDUCED_REDUNDANCY"  --cache-control "max-age=31536000" --acl "public-read" --sse "AES256"  static/downloads/ s3://$BUCKET_NAME/downloads/

# Invalidate landing page so everything sees new post - warning, first 1K/mo free, then 1/2 cent ea
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths /index.html / /blog/ /blog/index.html

