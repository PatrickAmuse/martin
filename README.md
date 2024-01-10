@Amuse, 

note: this is all pretty hacky, eventually we want to be back on the main martin image, once it has fixes our database_url issue
We are leveraging our repo with our customized martin server to create our docker images.
We have added binaries(unix) and apple binaries which contain the binaries built by our github actions.
We have a new amuse.Dockerfile, which we use to build our custom docker image.
This is all in the github->files folder, because like i said...hacky.

You then need to tag and upload that image to the our DO docker repo using 
  docker tag martin_amuse_prod registry.digitalocean.com/amuse/image_name
  docker push registry.digitalocean.com/amuse/image_name
our image names are martin_amuse for dev and martin_amuse_prod for prod

if we need a newer version of martin we need to upgrade our fork, make sure the fixes we already put in are still applied, build new binaries using github actions, and then replace our existing binaries with those new ones.
Alternatively we just add our stuff to the open source repo. There is an existing ticket for it.

  


[![Martin](https://raw.githubusercontent.com/maplibre/martin/main/logo.png)](https://maplibre.org/martin/)

[![Book](https://img.shields.io/badge/docs-Book-informational)](https://maplibre.org/martin)
[![docs.rs docs](https://docs.rs/martin/badge.svg)](https://docs.rs/martin)
[![Slack chat](https://img.shields.io/badge/Chat-on%20Slack-blueviolet)](https://slack.openstreetmap.us/)
[![GitHub](https://img.shields.io/badge/github-maplibre/martin-8da0cb?logo=github)](https://github.com/maplibre/martin)
[![crates.io version](https://img.shields.io/crates/v/martin.svg)](https://crates.io/crates/martin)
[![Security audit](https://github.com/maplibre/martin/workflows/Security%20audit/badge.svg)](https://github.com/maplibre/martin/security)
[![CI build](https://github.com/maplibre/martin/actions/workflows/ci.yml/badge.svg)](https://github.com/maplibre/martin/actions)
[![](https://img.shields.io/badge/Slack-%23maplibre--martin-2EB67D?logo=slack)](https://slack.openstreetmap.us/)

Martin is a tile server able to generate and serve [vector tiles](https://github.com/mapbox/vector-tile-spec) on the fly from large [PostGIS](https://github.com/postgis/postgis) databases, [PMTile](https://protomaps.com/blog/pmtiles-v3-whats-new), and [MBTile](https://github.com/mapbox/mbtiles-spec) files, allowing multiple tile sources to be dynamically combined into one. Martin optimizes for speed and heavy traffic, and is written in [Rust](https://github.com/rust-lang/rust).

Additionally, there are [several tools](https://maplibre.org/martin/tools.html) for generating tiles in bulk from any Martin-supported sources (similar to `tilelive-copy`), copying tiles between MBTiles files, creating deltas (patches) and applying them, and validating MBTiles files.

See [Martin book](https://maplibre.org/martin/) for complete documentation.

## Installation

_See [installation instructions](https://maplibre.org/martin/installation.html) in the Martin book._

**Prerequisites:** If using Martin with PostgreSQL database, you must install PostGIS with at least v3.0+, v3.1+ recommended.

You can download martin from [GitHub releases page](https://github.com/maplibre/martin/releases).

| Platform | AMD-64                                                                                           | ARM-64                              |
|----------|--------------------------------------------------------------------------------------------------|-------------------------------------|
| Linux    | [.tar.gz][rl-linux-x64] (gnu)<br>[.tar.gz][rl-linux-x64-musl] (musl)<br>[.deb][rl-linux-x64-deb] | [.tar.gz][rl-linux-a64-musl] (musl) |
| macOS    | [.tar.gz][rl-macos-x64]                                                                          | [.tar.gz][rl-macos-a64]             |
| Windows  | [.zip][rl-win64-zip]                                                                             |                                     |

[rl-linux-x64]: https://github.com/maplibre/martin/releases/latest/download/martin-x86_64-unknown-linux-gnu.tar.gz
[rl-linux-x64-musl]: https://github.com/maplibre/martin/releases/latest/download/martin-x86_64-unknown-linux-musl.tar.gz
[rl-linux-x64-deb]: https://github.com/maplibre/martin/releases/latest/download/martin-Debian-x86_64.deb
[rl-linux-a64-musl]: https://github.com/maplibre/martin/releases/latest/download/martin-aarch64-unknown-linux-musl.tar.gz
[rl-macos-x64]: https://github.com/maplibre/martin/releases/latest/download/martin-x86_64-apple-darwin.tar.gz
[rl-macos-a64]: https://github.com/maplibre/martin/releases/latest/download/martin-aarch64-apple-darwin.tar.gz
[rl-win64-zip]: https://github.com/maplibre/martin/releases/latest/download/martin-x86_64-pc-windows-msvc.zip

If you are using macOS and [Homebrew](https://brew.sh/) you can install `martin` and `mbtiles` using Homebrew tap.

```shell
brew tap maplibre/martin
brew install martin
```

## Running Martin Service

_See [running instructions](https://maplibre.org/martin/run.html) in the Martin book._

Martin supports any number of PostgreSQL/PostGIS database connections with [geospatial-enabled](https://postgis.net/docs/using_postgis_dbmanagement.html#geometry_columns) tables and tile-producing SQL functions, as well as [PMTile](https://protomaps.com/blog/pmtiles-v3-whats-new) and [MBTile](https://github.com/mapbox/mbtiles-spec) files as tile sources.

Martin can auto-discover tables and functions using a [connection string](https://maplibre.org/martin/pg-connections.html). A PG connection string can also be passed via the `DATABASE_URL` environment variable.

Each tile source will have a [TileJSON](https://github.com/mapbox/tilejson-spec) endpoint.

#### Examples

```shell
# publish all tables and functions from a single database
export DATABASE_URL="postgresql://user:password@host:port/database"
martin

# same as above, but passing connection string via CLI, together with a directory of .mbtiles/.pmtiles files
martin postgresql://user:password@host:port/database path/to/dir

# publish all discovered tables/funcs from two DBs
# and generate config file with all detected sources
martin postgres://... postgres://...  --save-config config.yaml

# use configuration file instead of auto-discovery
martin --config config.yaml
```

#### Docker Example

_See [Docker instructions](https://maplibre.org/martin/run-with-docker.html) in the Martin book._

Martin is also available as a [Docker image](https://ghcr.io/maplibre/martin). You could either share a configuration file from the host with the container via the `-v` param, or you can let Martin auto-discover all sources e.g. by passing `DATABASE_URL` or specifying the .mbtiles/.pmtiles files.

```shell
export PGPASSWORD=postgres  # secret!
docker run -p 3000:3000 \
           -e PGPASSWORD \
           -e DATABASE_URL=postgresql://user@host:port/db \
           -v /path/to/config/dir:/config \
           ghcr.io/maplibre/martin --config /config/config.yaml
```

## API

_See [API documentation](https://maplibre.org/martin/using.html) in the Martin book._

Martin data is available via the HTTP `GET` endpoints:

| URL                                     | Description                                   |
|-----------------------------------------|-----------------------------------------------|
| `/`                                     | Status text, that will eventually show web UI |
| `/catalog`                              | List of all sources                           |
| `/{sourceID}`                           | Source TileJSON                               |
| `/{sourceID}/{z}/{x}/{y}`               | Map Tiles                                     |
| `/{source1},…,{sourceN}`                | Composite Source TileJSON                     |
| `/{source1},…,{sourceN}/{z}/{x}/{y}`    | Composite Source Tiles                        |
| `/sprite/{spriteID}[@2x].{json,png}`    | Sprites (low and high DPI, index/png)         |
| `/font/{font}/{start}-{end}`            | Font source                                   |
| `/font/{font1},…,{fontN}/{start}-{end}` | Composite Font source                         |
| `/health`                               | Martin server health check: returns 200 `OK`  |

## Documentation

See [Martin book](https://maplibre.org/martin/) for complete documentation.

## License

Licensed under either of

* Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)
  at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the
Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.
