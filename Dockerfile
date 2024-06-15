FROM eclipse-temurin:8-jdk AS dependency-builder
WORKDIR application
COPY .mvn .mvn
COPY pom.xml mvnw ./
RUN sed -i 's/\r$//' mvnw
RUN ./mvnw -B dependency:resolve-plugins dependency:go-offline verify --fail-never

FROM dependency-builder AS application-builder
COPY . .
RUN sed -i 's/\r$//' mvnw
RUN ./mvnw -B -Dmaven.test.skip=true clean package

FROM eclipse-temurin:8-jre-jammy
WORKDIR application
COPY --from=application-builder application/target/*.jar ./api.jar
CMD ["java", "-jar", "api.jar"]