//declarative pipeline

pipeline {
  agent any
    options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    environment {
     DOCKERHUB_CREDENTIALS = credentials('dockerhub')
     SSH_CREDENTIALS = credentials('ssh_into_ec2')
     EC2_INSTANCE_IP = '54.234.74.127'
     EMAIL_RECIPIENTS = 'shivani.aher@persistent.com'
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
                       def sshCommand = """
                            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ec2-user@\$EC2_INSTANCE_IP 'echo Hello from SSH'
                            """
                        try {
                            sh sshCommand
                            sh """
                            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ec2-user@\$EC2_INSTANCE_IP << 'EOF'
                                docker pull ahershiv/to-do-node-app
                                docker stop to-do-node-app || true
                                docker rm to-do-node-app || true
                                docker run -d -p 8000:8000 --name to-do-node-app ahershiv/to-do-node-app
                            EOF
                        """
                    } catch (Exception e) {
                            error("Failed to execute SSH command: ${e.message}")
                            currentBuild.result = 'FAILURE'
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
   post {
        success {
            emailext subject: "Build Success - ${currentBuild.fullDisplayName}",
                      body: "The build of ${env.JOB_NAME} ${env.BUILD_NUMBER} is successful.",
                      to: EMAIL_RECIPIENTS
        }
        failure {
            emailext subject: "Build Failure - ${currentBuild.fullDisplayName}",
                      body: "The build of ${env.JOB_NAME} ${env.BUILD_NUMBER} has failed.\n\nConsole Output:\n${Jenkins.instance.getItem(env.JOB_NAME).getBuildByNumber(env.BUILD_NUMBER).getLog(100)}",
                      to: EMAIL_RECIPIENTS
        }
   }
}
