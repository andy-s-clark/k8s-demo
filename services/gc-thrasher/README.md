# gc-thrasher

Cause lots of GC by hitting the `/gcthrash` endpoint. Optional query parameters:
* `blockSize`
* `retries`

Based on the [Stack Overflow question "Force JVM to thrash due to constant GC"](https://stackoverflow.com/questions/44035964/force-jvm-to-thrash-due-to-constant-gc)

_Credit to Russell Johnston for the idea and the initial implementation._

## Docker

    docker build -t gc-thrasher .
    docker run --rm -p 8080:8080 -p 9393:9393 -it gc-thrasher

## Example Requests

    curl localhost:9393/app/health
    curl localhost:8080/gcthrash

## Local Development

### Pre-Requisites

* Java 11+
* Maven

### Build Steps

    mvn package

### Run from the command line

    java -jar target/gc-thrasher.jar
