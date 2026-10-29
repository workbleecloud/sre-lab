# sre-lab

One of my first hands-on labs, from September 2026. It covers the basics: building Docker images, Bash scripts to build and deploy them with a health check, a small Python service, and a GitHub Actions workflow that builds and tests it.

It's a learning lab, not something running in production. My next lab, a Helm-deployed app on a local Kubernetes cluster behind Kong, is [kong-sre-lab](https://github.com/workbleecloud/kong-sre-lab).

## What's in it

```
web/        static page served by nginx (nginx:alpine)
python/     Python API using only the standard library: GET / and GET /health
bash/       build-image.sh, deploy.sh, hello.sh, sre-demo.sh
.github/    CI workflow
```

## Scripts

Run these from the repo root, since they call `git` and use relative paths.

- `build-image.sh` builds the web image and tags it with the short commit SHA (`sre-web:<sha>`), so I can always tell which commit an image came from.
- `deploy.sh` checks that the image exists, removes the old `sre-web` container if there is one, starts the new one on port 8080, and checks it up to 5 times. If it never responds, the script exits with an error.
- `hello.sh` prints some basic system info (host, user, disk, memory) and exits with an error if the root disk is 80% full or more.
- `sre-demo.sh` is a fake long-running service that prints a heartbeat every 10 seconds.

The build and deploy scripts use `set -euo pipefail`, so they stop on the first command that fails.

## CI

On every push to `main`, the workflow in `.github/workflows/ci.yml` builds the Python image, starts a container, and calls `/health` up to 5 times. If it never gets a response, the run fails.

## Running it

```bash
./bash/build-image.sh && ./bash/deploy.sh    # web page at http://localhost:8080

docker build -t sre-api ./python
docker run -d -p 8081:8000 sre-api
curl localhost:8081/health                  # {"status": "healthy"}
```
