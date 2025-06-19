pipeline {
  agent any

  environment {
    S3_BUCKET = 's3-bucket-for-darvixassessment '
    AWS_REGION = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/rohituser/Assessment.git', branch: 'master'
      }
    }

    stage('Build') {
      steps {
        sh '''
          mkdir -p build
          cp index.html build/
        '''
      }
    }

    stage('Package') {
      steps {
        sh 'zip -r app.zip build/*'
      }
    }

    stage('Upload to S3') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'your-aws-creds-id') {
          sh 'aws s3 cp app.zip s3://${S3_BUCKET}/app.zip'
        }
      }
    }

    stage('Deploy to EC2 (ASG)') {
      steps {
        echo 'Triggering ASG rolling update or use SSM/Ansible to deploy to EC2'
        // Example: trigger ASG refresh or use SSH-based deploy
      }
    }
  }
}
