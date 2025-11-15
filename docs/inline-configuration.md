# `docker-compose` inline configuration

Rather than a `config.json` file, you can pass the configuration inline from your `docker-compose.yml` file like this:

```yaml
  environment:
    PUBLIC_BASE_URL: https://your-proxy-url.com
    IMMICH_URL: http://your-internal-immich-server:2283
    CONFIG: |
      {
        "ipp": {
          "singleImageGallery": false,
          ...
        }
      }
```
