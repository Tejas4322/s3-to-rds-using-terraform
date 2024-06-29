
# S3-TO-RDS Using Jenkins and Terraform 

#### This project demonstrates that how can we read data from s3 and push it to RDS using jenkins and Terraform:
- Setting up an EC2 instance for Jenkins.
- Building a Docker image and pushing it to AWS ECR.
- Creating a Lambda function using Terraform that uses the Docker image pushed in ECR to push data to RDS.


#### Prerequisites


- AWS CLI configured
- Terraform installed
- Docker installed
- Jenkins installed (on an EC2 instance)
- RDS instance setup
- Fork the repo for personalization
## Step 1: Setting Up an EC2 Instance for Jenkins and RDS database

### 1 . Launch EC2 Instance

    1. Go to the AWS Management Console.
    2. Navigate to EC2 and launch a new instance of name (jenkins-master).
    3. Provision an EC2 instance on AWS with Ubuntu 22.04.
    4. Choose an instance type (atleast t2.small).
    5. Configure instance details and add storage (atleast 10gb).
    6. Configure security group to allow SSH (port 22), HTTP (port 80), and Jenkins (port 8080).
    7. Launch the instance and connect via SSH.

### 2 . Create an IAM Role for ec2 instance and attach the following policies as shown in the image : 
![Screenshot 2024-06-29 214458](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/f890755a-4e25-4955-8095-aebc9a56e1c7)


**Attach the role created to the ec2 instance.**

### 3. Install jenkins on jenkins-server

- For installation of jenkins you can checkout the setup files . 
- Access Jenkins at http://<EC2-Public-IP>:8080 .
*If you are not creating a user in jenkins, make sure to copy the password jenkins gives you at the start*
```
cat /var/lib/jenkins/secrets/initialAdminPassword
```  
- Follow the setup wizard to unlock Jenkins, install suggested plugins, and create an admin user.
- Go to Dashboard > Manage Jenkins > Plugins > Available Plugins , and install the following plugins.
![Screenshot 2024-06-29 204429](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/5993090a-61f9-4632-a0c3-c7d4c5645c89)


### 4. Create a RDS database 
- Create a RDS databse using easy create also select MySql and hit create .
- After creation click on modify and enable public access.
- Create a new database and a table to insert data. 

![Screenshot 2024-06-29 202947](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/7691e577-b7a3-4342-ab99-f761cc9c9a11)


## Step 2: Building and Pushing a Docker Image to AWS ECR

***Before moving forward please update the bucket name and other variable in the app.py file .***

### 1 . Install docker ans aws cli on jenkins-server

- For installation of docker and aws cli you can checkout the setup file.
- After installing docker run the following commands to grant acess to the user and jenkins to docker : 

```
sudo chmod 666 /var/run/docker.sock
sudo usermod -a -G docker $USER
sudo usermod -a -G docker jenkins
```
- Restart you jenkins server using the command:
```
sudo systemctl restart jenkins
```
*Wait for few minutes till jenkins restarts*
- Check if jenkins server is again up and running through command:
```
sudo systemctl status jenkins
```
- Configure your aws credentials using command:
```
aws configure
```
*Fill the credentials and desired region*

### 2 . Setting up pipeline for Building and pushing docker image to ECR:

- Go to Jenkins home > New Item > pipeline 
- To build and push docker image to ecr put this script to check if it is working:
```
pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="177537930619" - change to your acc id
        AWS_DEFAULT_REGION="us-east-1" - change region if needed
        IMAGE_REPO_NAME="s3-to-rds" - change to your ecr registry name
        IMAGE_TAG="latest" - change the tag if needed
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                # update this step by using pipeline syntax > checkout: checkout fom version contro;
                checkout scm
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
    }
}        
```
![Screenshot 2024-06-29 205944](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/4158f0ae-17be-4de2-a679-75223663e322)


## Step 3: Using Terraform to Create a Lambda Function

### 1 . Install terraform on jenkins-server

- For installation of terraform you can checkout the setup file.

### 2 . Update the terraform file 
- Put your variable in the variables.tf file .
- Change the backend.tf bucket name or you can also remove the file to save state file of terraform locally. 
- Go to your pipeline > Configure > This project is parameterized and tick the box .
![Screenshot 2024-06-29 204704](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/f2d17274-c222-4930-b4cc-850ca253635d)

- Update your script and save
```
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
    # update this step by using pipeline syntax > checkout: checkout fom version contro;
                checkout scm
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
```

- Build the pipeline using parameter apply 

![Screenshot 2024-06-29 205424](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/defcb6d3-1d90-4891-8ce5-cc4782ba0e99)

![Screenshot 2024-06-29 210122](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/f0e9b7e3-eb53-4175-8195-2342c986450b)


### 3 . Verify the lambda function

- Check the lambda dashboard , you'll se the function whith s3 trigger.

![Screenshot 2024-06-29 210359](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/603bc4be-0699-413e-b617-943dac419a0e)

- Push a file to s3 and check the databse.

![Screenshot 2024-06-29 210747](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/8f521486-cabc-4857-9403-cdddf82033fe)


- You can also watch logs on cloudwatch log group if the data is pushed successfully. 

![Screenshot 2024-06-29 210734](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/1a562ad3-b604-438f-bb90-ce0bb8c74cfe)


- To destroy the terreform resources change the parameter to destroy and run the pipeline.

![Screenshot 2024-06-29 211009](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/dc9dfaca-32c0-4e95-9ff3-6f0c42c247bf)


![Screenshot 2024-06-29 211306](https://github.com/Tejas4322/s3-to-rds-using-terraform/assets/141610398/215e609d-52bf-4512-8873-9b3796796721)

