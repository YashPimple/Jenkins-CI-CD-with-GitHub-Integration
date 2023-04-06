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
        docker build -t nodeapp:${BUILD_NUMBER}
      }
     }
     stage('Test'){
        steps{
          sh ''
          docker run -it nodeapp:$(BUILD_NUMBER)
      }
     }
      stage('Package'){
        steps{
          sh ''
          docker push yashpimple22/nodeapp:$(BUILD_NUMBER)
          '''
      }
     }
  }
}
