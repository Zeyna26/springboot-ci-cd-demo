pipeline {
    agent any

    stages {

        // Stage de préparation – Vérifie que les outils sont installés
        stage('Préparation (Before Script)') {
            steps {
                echo 'Vérification des outils installés'
                sh 'java -version'
                sh 'mvn -version'
                sh 'docker --version'
            }
        }

        // Job 1 – Compilation avec Maven
        stage('Build Maven') {
            steps {
                echo 'Compilation du projet Spring Boot'
                sh 'mvn clean'
                sh 'mvn package -DskipTests'
            }
        }

        // Job 2.1 – Construction de l’image Docker
        stage('Docker Build') {
            steps {
                echo 'Construction de l’image Docker'
                sh 'docker build -t seynabou02/springboot-ci-cd-demo:latest .'
            }
        }

        // Job 2.2 – Exécution du conteneur Docker
        stage('Docker Run') {
            steps {
                echo 'Lancement du conteneur Docker'
                sh 'docker run -d -p 8081:8080 seynabou02/springboot-ci-cd-demo:latest'
            }
        }

        // Job 2.3 – Push vers Docker Hub
        stage('Docker Push') {
            steps {
                echo 'Push de l’image sur Docker Hub'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh 'docker push seynabou02/springboot-ci-cd-demo:latest'
                }
            }
        }
    }
}
