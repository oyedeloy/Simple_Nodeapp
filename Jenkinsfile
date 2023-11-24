pipeline {
    agent any

    environment {
        // Define Docker image and tag
        DOCKER_IMAGE = 'oyedeloy/Simple_Nodeapp' // Replace with your actual Docker image name
        DOCKER_TAG = 'Version_01' // Replace with your actual Docker tag
        // Define registry credentials ID
        DOCKER_CREDENTIALS_ID = 'Docker_hub'
    }

    stages {
        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Log in to Docker Hub and build/push the Docker image
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS_ID) {
                        // Building Docker image
                        def app = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "-f Dockerfile .")

                        // Pushing Docker image
                        app.push()
                    }
                }
            }
        }

        // You can add other stages like testing, deployment, etc., here
    }

    post {
        success {
            echo 'Docker image build and push to Docker Hub completed successfully.'
        }
        failure {
            echo 'Docker image build and push to Docker Hub failed.'
        }
    }
}
