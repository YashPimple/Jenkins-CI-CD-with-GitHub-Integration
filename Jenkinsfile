//declarative pipeline

pipeline {
  agent any
    options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    environment {
     DOCKERHUB_CREDENTIALS = credentials('dockerhub')
     SSH_CREDENTIALS = credentials('ssh_into_ec2')
     EC2_INSTANCE_IP = '54.224.187.46'
    }
     stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout code from the 'test' branch
                    checkout([$class: 'GitSCM', branches: [[name: 'test']], userRemoteConfigs: [[url: 'https://github.com/aher24shivani/sample-node-cicd.git']]])
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    // Install Node.js dependencies
                    sh 'npm install --save-dev mocha chai'
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    // Build the application using docker image
                    sh 'docker build . -t ahershiv/to-do-node-app'
                }
            }
        }

        stage('Login') {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'      
         }        
        }
        
        stage('Push') {
      steps {
        sh 'docker push ahershiv/to-do-node-app'
        }
       }

        stage('Run Tests') {
            steps {
                script {
                    // Run Mocha tests
                    sh 'npm test'
                }
            }
        }

         stage('Deploy to Stage') {
            steps {
                script {
                    // Stage environment set on ec2 instance
                    withCredentials([sshUserPrivateKey(credentialsId: 'ssh_into_ec2', keyFileVariable: 'SSH_KEY')]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ec2-user@\$EC2_INSTANCE_IP << 'EOF'
                                docker pull ahershiv/to-do-node-app
                                docker stop to-do-node-app || true
                                docker rm to-do-node-app || true
                                docker run -d -p 8000:8000 --name to-do-node-app ahershiv/to-do-node-app
                            EOF
                        """
                    }
                }
            }
        }    
    }

    post {
      always {
            // Cleanup or additional steps that should be executed regardless of the build result
               cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}

