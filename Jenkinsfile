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

stage('Vérification du code source') {
    steps {
        sh '''
            echo "Répertoire courant :"
            pwd

            echo "Structure du projet :"
            find . -type f

            echo "Contenu du dossier k8s :"
            find . -name "*.yaml"
        '''
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
stage('DEBUG WORKSPACE') {
    steps {
        echo "Affichage du chemin de travail de Jenkins"
        sh '''
            echo "WORKSPACE = $WORKSPACE"
            echo "Contenu du WORKSPACE :"
            ls -alh $WORKSPACE

            echo "Contenu de $WORKSPACE/k8s :"
            ls -alh $WORKSPACE/k8s
        '''
    }
}

stage('Deploy to EKS') {
    steps {
        echo 'Déploiement sur le cluster EKS'
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
            sh '''
                aws eks update-kubeconfig --region eu-north-1 --name eks-sey

                echo "[DEBUG] Position actuelle : $(pwd)"
                echo "[DEBUG] Liste des fichiers YAML trouvés :"
                find . -name "*.yaml"

                DEPLOYMENT_FILE=$(find . -type f -name deployment.yaml | head -n 1)
                SERVICE_FILE=$(find . -type f -name service.yaml | head -n 1)

                echo "Déploiement de : $DEPLOYMENT_FILE"
                kubectl apply -f $DEPLOYMENT_FILE

                echo "Déploiement de : $SERVICE_FILE"
                kubectl apply -f $SERVICE_FILE
            '''
        }
    }
}

    }
}
