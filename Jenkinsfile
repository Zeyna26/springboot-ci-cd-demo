pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'eu-north-1'
    }

    stages {

        stage('Checkout code') {
            steps {
                echo 'Clonage du dépôt Git...'
                checkout scm
                sh 'echo "[DEBUG] Contenu du repo après checkout:"'
                sh 'ls -R'
            }
        }

        stage('Préparation (Before Script)') {
            steps {
                echo 'Vérification des outils installés'
                sh 'java -version'
                sh 'mvn -version'
                sh 'docker --version'
            }
        }

        stage('Build Maven') {
            steps {
                echo 'Compilation du projet Spring Boot'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Construction de l’image Docker'
                sh 'docker build -t seynabou02/springboot-ci-cd-demo:latest .'
            }
        }

        stage('Docker Run') {
            steps {
                echo 'Lancement du conteneur Docker'
                sh '''
                    if docker ps -a | grep -q "springboot-ci-cd-demo"; then
                        docker rm -f $(docker ps -a | grep "springboot-ci-cd-demo" | awk '{print $1}')
                    fi
                    docker run -d -p 8081:8080 --name springboot-ci-cd-demo seynabou02/springboot-ci-cd-demo:latest
                '''
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Push de l’image sur Docker Hub'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh 'docker push seynabou02/springboot-ci-cd-demo:latest'
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo 'Déploiement sur le cluster EKS'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                        aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name eks-sey
                        echo "[DEBUG] Contenu de k8s/ :"
                        ls -alh ${WORKSPACE}/k8s
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }
}
