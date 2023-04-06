//declarative pipeline

pipeline{
  stages{
    stage('Clone'){
      steps {
        git branch: 'master'
        url: '"
      }
    }
     stage('Build'){
      steps{
        sh ''
        docker build -t web-game:${BUILD_NUMBER}
      }
     }
//      stage('Test'){
//         steps{
//           sh ''
//           docker run -it web-game:$(BUILD_NUMBER)
//       }
//      }
      stage('Package'){
        steps{
          sh ''
          docker push yashpimple22/web-game:$(BUILD_NUMBER)
          '''
      }
     }
     
     
     
      stage('Updating deployment.yaml'){
          steps {
//             withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
//                 sh '''
//                     //git config user.email "yash.xyz@gmail.com"
                    git config user.name "YashPimple"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s/latest/${BUILD_NUMBER}/g" Manifest/deployment.yaml
                    git add Manifest/deployment.yaml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                '''
//             }
        }
     }
    
  }
}
