pipeline {
  agent any

  environment {
    IMAGE_NAME_WEB = "msdw-mbp_main-web"
    PROD_SERVER = "10.0.21.29"
    PROD_USER = "ec2-user"
    DEV_SERVER = "10.0.28.126"
    DEV_USER = "ubuntu"
    CICD_SERVER = "10.0.24.168"
    CICD_USER = "ec2-user"
    SSH_CREDENTIALS_ID_PROD = 'ssh-aouth-ekscontrol'
    SSH_CREDENTIALS_ID_DEV = 'ssh-to-dev-server'
    SSH_EKS_CREDS = 'ssh-ekscontrol'
    APP_NAME = "status-page"
    REMOTE_REGISTRY = "992382545251.dkr.ecr.us-east-1.amazonaws.com/msdw/statuspage-web"
    DEPLOY_ENV = "${BRANCH_NAME == 'main' ? 'production' : 'development'}"
    SLACK_CHANNEL = '#devops-alerts'
  }

  stages {

    stage('Dev Build') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh '[ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0777 ~/.ssh'
          sh "ssh-keyscan -t rsa,dsa $DEV_SERVER >> ~/.ssh/known_hosts"
          sh "ssh -t $DEV_USER@$DEV_SERVER 'cd /opt/msdw-statuspage; docker build -t msdw/statuspage-web .; aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com; docker tag msdw/statuspage-web $REMOTE_REGISTRY:dev-test; docker push $REMOTE_REGISTRY:dev-test'"
        }
      }
    }

    stage('runing the image test') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh "ssh -t $DEV_USER@$DEV_SERVER 'docker run -d --rm msdw/statuspage-web'"
        }
      }
    }

    stage('Dev upload to ECR') {
      when { changeRequest() }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh  "ssh -t $DEV_USER@$DEV_SERVER 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com; docker tag msdw/statuspage-web $REMOTE_REGISTRY:pr-${CHANGE_ID}; docker push $REMOTE_REGISTRY:pr-${CHANGE_ID};'"
        }
      }
    }

    stage('Deploy latest version to ecr') {
      when { branch 'main'}
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_DEV"]) {
          sh '[ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0777 ~/.ssh'
          sh  "ssh -t $DEV_USER@$DEV_SERVER 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com;  docker build -t msdw/statuspage-web .; docker tag msdw/statuspage-web $REMOTE_REGISTRY:v$BUILD_NUMBER; docker push $REMOTE_REGISTRY:v$BUILD_NUMBER'"
           }
       }
     }
          
    stage('Deploy to EKS') {
      when { branch 'main' }
      steps {
        sshagent(credentials: ["$SSH_CREDENTIALS_ID_PROD"]) {
          sh "ssh-keyscan $PROD_SERVER >> ~/.ssh/known_hosts"
          sh "ssh -t $PROD_USER@$PROD_SERVER 'kubectl set image deployment/web *=$REMOTE_REGISTRY:v$BUILD_NUMBER; kubectl rollout status deployment/web'"     
                 }
              }
           
         
      post {
        failure {
          sshagent(credentials ["$SSH_CREDENTIALS_ID_PROD"])
            echo "Deployment failed! Rolling back..."
            sh "ssh -t $PROD_USER@$PROD_SERVER 'kubectl rollout undo deployment/web'"
            error("Rollback executed due to failure.")
          }
        }
      }
    }
 }
  


