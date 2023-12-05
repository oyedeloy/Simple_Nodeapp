pipeline {
    agent any

    environment {
        // Docker environment variables
        DOCKER_IMAGE = 'oyedeloy/simple_nodeapp' // Replace with your actual Docker image name
        DOCKER_TAG = 'Version_02' // Replace with your actual Docker tag
        DOCKER_CREDENTIALS_ID = 'Docker_hub'

        // AWS environment variable
        AWS_REGION = 'us-east-2'
    }

    stages {
        stage('Build and Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS_ID) {
                        def app = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "-f Dockerfile .")
                        app.push()
                    }
                }
            }
        }

        stage('Terraform Apply') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('ACCESS_KEY')
                AWS_SECRET_ACCESS_KEY = credentials('SECRET_KEY')
            }
            steps {
                sh 'terraform init'
                sh 'terraform plan'
                sh 'terraform destroy -auto-approve'
            }
        }
        stage('Invoke ansible playbook') {
            steps {
                script {
                    // Add your SSH key credential here for Ansible
                    sshagent(credentials: ['ec2-user']) {
                        sh 'sudo ansible-playbook -i /home/dele/Inventory --user ubuntu --private-key /home/dele/Java_key2.pem config.yaml --vault-password-file /home/dele/vault_password.txt'
                    }
                }
            }
        }
            

        // Additional stages from your original Jenkinsfiles can be added here
    }

    post {
        success {
            echo 'Pipeline executed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
