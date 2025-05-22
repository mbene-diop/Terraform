pipeline {
    agent any

    tools {
        terraform 'Terraform-kuber'  // Le nom  donné dans Jenkins pour Terraform
    }

    stages {
        stage('Checkout du code') {
            steps {
                git branch: 'main', url: 'https://github.com/Aissatou022/Terraform.git'
            }
        }

        stage('Initialisation de Terraform') {
            steps {
                bat 'terraform init'
            }
        }

        stage('Plan Terraform') {
            steps {
                bat 'terraform plan'
            }
        }

        stage('Application de Terraform') {
            steps {
                bat 'terraform apply -auto-approve'
            }
        }
    }
}
