//declarative pipeline

pipeline {
    agent any

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
                    sh 'docker build . -t to-do-node-app'
                }
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
        }
    }
}

