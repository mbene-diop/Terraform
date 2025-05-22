environment {
    KUBECONFIG = '/var/lib/jenkins/.kube/config'
}
pipeline {
    agent any

    tools {
        terraform 'MonProjet'  // Le nom  donné dans Jenkins pour Terraform
    }

    stages {
        stage('Checkout du code') {
            steps {
                git branch: 'main', url: 'https://github.com/mbene-diop/Terraform.git'
            }
        }

        stage('Initialisation de Terraform') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Plan Terraform') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Application de Terraform') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }
}
