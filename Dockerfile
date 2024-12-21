FROM alpine:3.21 AS base

RUN apk add --no-cache \
  gc \
  mesa-dri-gallium \
  mesa-utils \
  pcre2 \
  xvfb-run

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["glxinfo"]

FROM crystallang/crystal:1.14-alpine AS spec-builder

RUN apk add --no-cache \
  glfw

WORKDIR /src
COPY shard.yml ./
RUN shards install
COPY . .
RUN shards build specs --debug

FROM base AS spec
COPY --from=spec-builder /src/bin/specs /specs
CMD ["/specs"]
