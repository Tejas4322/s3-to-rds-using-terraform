pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="177537930619"
        AWS_DEFAULT_REGION="us-east-1"
        IMAGE_REPO_NAME="s3-to-rds"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Tejas4322/s3-to-rds-using-terraform']])
            }
        }
        
        stage('Logging in into AWS ECR') {
            steps {
                script {
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }
                 
            }
        }
        
        stage('Docker Build'){
            steps {
                script {
                    dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}" 
                }    
            }   
        
        }
        
        stage('Pushing the image to ECR') {
            steps{  
                script {
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
            }
            
        }

        stage('Terraform init') {
            steps{
                sh ("terraform init --reconfigure")
            }
        }

        stage('Terraform plan') {
            steps{
                sh ("terraform plan")
            }
        }

        stage('Terraform action') {
            steps{
                echo "Terraform action is -> ${action}"
                sh ("terraform ${action} --auto-approve")
            }
        }
    }
}