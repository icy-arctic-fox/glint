FROM alpine:3.21 AS base

RUN apk add --no-cache \
  gc \
  glfw \
  mesa-dri-gallium \
  mesa-utils \
  pcre2 \
  xvfb-run

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["glxinfo"]

FROM crystallang/crystal:1.14-alpine AS spec-builder

RUN apk add --no-cache \
  glfw-dev

WORKDIR /app
COPY shard.yml ./
RUN shards install
COPY . .
RUN shards build specs --debug

FROM base AS spec
COPY --from=spec-builder /app/bin/specs /specs
CMD ["/specs"]
