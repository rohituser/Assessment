pipeline {
    agent any

    environment {
        S3_BUCKET = 's3-bucket-for-darvixassessment'  // Removed the extra space
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout from the correct branch, assuming it's 'main' or 'master'
                    git url: 'https://github.com/rohituser/Assessment.git', branch: 'master'  // Update branch name if necessary
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    // Create build directory and copy index.html to it
                    sh '''
                      mkdir -p build
                      cp index.html build/
                    '''
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    // Package the build directory into a zip file
                    sh 'zip -r app.zip build/*'
                }
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials-id') {  // Replace with your actual AWS credentials ID in Jenkins
                    script {
                        // Upload the zip file to S3 bucket
                        sh 'aws s3 cp app.zip s3://${S3_BUCKET}/app.zip'
                    }
                }
            }
        }

        stage('Deploy to EC2 (ASG)') {
            steps {
                script {
                    echo 'Triggering ASG rolling update or using SSM/Ansible to deploy to EC2'
                    // Example: trigger ASG refresh or use SSH-based deploy
                    // You can use AWS CLI or other tools to update ASG
                    // Example using AWS CLI to trigger ASG rolling update:
                    sh 'aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-auto-scaling-group --desired-capacity 0'
                    sh 'aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-auto-scaling-group --desired-capacity 1'
                    
                    // Alternatively, use SSM to run a script on EC2 instances:
                    // sh 'aws ssm send-command --document-name "AWS-RunShellScript" --targets "Key=instanceIds,Values=your-instance-id" --parameters "commands=your-deployment-script.sh"'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
