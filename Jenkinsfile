pipeline {
    agent any

    environment {
        // Docker and AWS environment variables
        DOCKER_IMAGE = 'oyedeloy/simple_nodeapp' // Replace with your actual Docker image name
        DOCKER_TAG = 'Version_02' // Replace with your actual Docker tag
        DOCKER_CREDENTIALS_ID = 'Docker_hub'
        AWS_REGION = 'us-east-2'
        // Add a variable to control the flow based on Terraform operation
        TERRAFORM_OPERATION = 'apply' // Default to 'apply', change to 'destroy' as needed
    }

    stages {
        stage('Build and Push Docker Image') {
            when {
                expression { TERRAFORM_OPERATION == 'apply' }
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS_ID) {
                        def app = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "-f Dockerfile .")
                        app.push()
                    }
                }
            }
        }

        stage('Terraform Operation') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('ACCESS_KEY')
                AWS_SECRET_ACCESS_KEY = credentials('SECRET_KEY')
            }
            steps {
                sh 'terraform init'
                sh 'terraform plan'
                sh "terraform ${TERRAFORM_OPERATION} -auto-approve"
                script {
                    if (TERRAFORM_OPERATION == 'apply') {
                        // Capture the public IP output from Terraform
                        EC2_IP = sh(script: "terraform output public_ip", returnStdout: true).trim()
                    }
                }
            }
        }

        stage('Check EC2 Instance Readiness') {
            when {
                expression { TERRAFORM_OPERATION == 'apply' }
            }
            steps {
                script {
                    def instanceReady = false
                    while (!instanceReady) {
                        try {
                            sh "ping -c 1 ${EC2_IP}"
                            instanceReady = true
                        } catch (Exception e) {
                            // Wait for 30 seconds before retrying
                            sleep(30)
                        }
                    }
                }
            }
        }

        stage('Invoke ansible playbook') {
            when {
                expression { TERRAFORM_OPERATION == 'apply' }
            }
            steps {
                script {
                    sshagent(credentials: ['ec2-user']) {
                        sh 'sudo ansible-playbook -i /home/dele/Inventory --user ubuntu --private-key /home/dele/Java_key2.pem config.yaml --vault-password-file /home/dele/vault_password.txt'
                    }
                }
            }
        }

        // Additional stages can be added here
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
