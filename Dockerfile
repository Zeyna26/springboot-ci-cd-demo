# Utilise une image de base OpenJDK 17 slim
FROM openjdk:17-jdk-slim

# Argument pour le nom du fichier JAR (sera précisé à la construction)
ARG JAR_FILE=target/*.jar

# Copie le JAR dans l'image sous le nom app.jar
COPY ${JAR_FILE} app.jar

# Commande de lancement
ENTRYPOINT ["java", "-jar", "/app.jar"]
