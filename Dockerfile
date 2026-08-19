# syntax=docker/dockerfile:1

FROM alpine:3.21 AS build

RUN apk add --no-cache build-base linux-headers

WORKDIR /src
COPY . .

RUN make -f makefile -j"$(nproc)" all \
    && strip udp2raw \
    && ./udp2raw --help >/dev/null

FROM alpine:3.21 AS runtime

# udp2raw's --auto-rule option invokes iptables at runtime.
RUN apk add --no-cache iptables

COPY --from=build /src/udp2raw /usr/local/bin/udp2raw

ENTRYPOINT ["/usr/local/bin/udp2raw"]
CMD ["--help"]
