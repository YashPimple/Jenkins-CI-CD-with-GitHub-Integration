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
                    sh 'npm install'
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    // Build the application (adjust as needed)
                    sh 'npm run build'
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

        stage('Package') {
            steps {
                script {
                    // Package the application
                    sh 'npm run package'
                }
            }
        }
    }

    post {
        always {
            // Cleanup or additional steps that should be executed regardless of the build result
        }
    }
}

