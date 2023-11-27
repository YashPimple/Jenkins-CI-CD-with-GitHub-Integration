pipeline {
  agent any
    options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    environment {
     DOCKERHUB_CREDENTIALS = credentials('dockerhub')
    }
     stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout code from the 'test' branch
                    checkout([$class: 'GitSCM', branches: [[name: 'main']], userRemoteConfigs: [[url: 'https://github.com/aher24shivani/sample-node-cicd.git']]])
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

     /*   stage('Package') {
            steps {
                script {
                    // Package the application
                    sh ''
                }
            }
        }    */
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
