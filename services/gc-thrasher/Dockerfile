# Build package
FROM maven:3-openjdk-11 AS build
WORKDIR /opt/app
COPY . /opt/app
RUN mvn --fail-at-end --batch-mode package

# Setup run container
FROM openjdk:11-jre-slim

# Add java user
RUN adduser --system javarole \
    && mkdir -p /opt/app \
    && chown -R javarole /opt/app

# Change the work directory
WORKDIR /opt/app

# Copy app from build containter
COPY --from=build /opt/app/target/gc-thrasher.jar .
USER javarole
EXPOSE 8080
EXPOSE 9393

# Run
CMD java -jar gc-thrasher.jar
