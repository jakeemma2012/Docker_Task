# ==================== Stage 1: Build ====================
FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

# Copy Maven wrapper and pom.xml first (for dependency caching)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Make Maven wrapper executable
RUN chmod +x mvnw

# Download dependencies (cached layer)
RUN ./mvnw dependency:resolve -B

# Copy source code
COPY src src

# Build the application (skip tests for faster build)
RUN ./mvnw package -DskipTests -B

# ==================== Stage 2: Runtime ====================
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the default Spring Boot port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]