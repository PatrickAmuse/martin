
FROM alpine

LABEL org.opencontainers.image.description="Blazing fast and lightweight tile server with PostGIS, MBTiles, and PMTiles support"
COPY binaries/martin /usr/local/bin
#COPY applebinaries/martin /usr/local/bin
RUN chmod +x /usr/local/bin/martin

# Set the working directory inside the container
WORKDIR /app

# Copy the local files into the container
COPY config.yaml /app/config.yaml

ENTRYPOINT ["/usr/local/bin/martin"]
CMD ["--config", "/app/config.yaml"]
