def remote = [:]
remote.name = 'blockchain@test'
remote.host = '104.211.218.220'
remote.allowAnyHosts = true

pipeline{
    agent any

    environment{
      DOCKER_IMAGE_VERSION = "${currentBuild.number}"
      NAMESPACE = "jenkins-deployment"
      DOCKER_IMAGE = "mukulxinaam/xfinite-staking:${DOCKER_IMAGE_VERSION}"

      // CHANGE THE VALUE TO SPECIFIC BRANCH 
      MASTER_BRANCH = "deploy" 
    }

    stages{

      stage("Setting git env") {
        steps {
          script {
            env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
            env.GIT_AUTHOR = sh (script: 'git log -1 --pretty=%cn ${GIT_COMMIT}', returnStdout: true).trim()
            env.GIT_AUTHOR_EMAIL = sh (script: 'git log -1 --pretty=%ce ${GIT_COMMIT}', returnStdout: true).trim()
          }
        }
      }

      stage("Build docker image"){
        when {
          expression {
            BRANCH_NAME == MASTER_BRANCH
          }
        }

        steps{
          echo "========Building Docker Image========"
          sh "docker build -t ${DOCKER_IMAGE} . --no-cache"
        }
      }

      stage("Docker Push Image!!"){
        when {
          expression {
            BRANCH_NAME == MASTER_BRANCH
          }
        }

        steps{
          echo "========Pushing Docker Image========"
          withCredentials([string(credentialsId: 'DOCKER_HUB_CREDENTIALS', variable: 'DOCKER_HUB_CREDENTIALS')]) {
              sh "docker login -u tiwarishubham23 -p ${DOCKER_HUB_CREDENTIALS}"
          }

          sh "docker push ${DOCKER_IMAGE}"
        }
      }

      stage("Deploy on kubernetes!!"){
        when {
          expression {
            BRANCH_NAME == MASTER_BRANCH
          }
        }

        steps{
          echo "========Deploying Docker Image========"
          sh 'sed "s, mukulxinaam/xfinite-staking.*, ${DOCKER_IMAGE}, g" deployment.yaml > temp.yaml' 
          sh "mv temp.yaml deployment.yaml"
          
          withCredentials([usernamePassword(
            credentialsId: 'HOST_MACHINE_CREDENTIAL', 
            passwordVariable: 'HOST_MACHINE_PASSWORD', 
            usernameVariable: 'HOST_MACHINE_USERNAME'
          )]){
            script{
              remote.user = HOST_MACHINE_USERNAME
              remote.password = HOST_MACHINE_PASSWORD
            }
            sshPut remote: remote, from: 'deployment.yaml', into: '.'
          }
          
          // uncomment below cmd to deploy it on kubernetes
          sh 'kubectl apply -f deployment.yaml'

          sh "rm -rf deployment.yaml"
        }
      }
      
    }

    post{
      success{
        script{
          if(env.BRANCH_NAME == MASTER_BRANCH){
            echo "========Pipeline executed successfully!!!========"
            emailext body: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]", 
            recipientProviders: [
              [$class: 'DevelopersRecipientProvider'], 
              [$class: 'RequesterRecipientProvider']
            ] , 
            // to: 'shubham@xfinite.io',
            subject: "Xfinite-io '${env.JOB_NAME}' (${env.BUILD_NUMBER})"
          }
        }
      }
      failure{
        echo "========Pipeline execution failed========"
      }
    }
}
