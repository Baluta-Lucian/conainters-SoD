pipeline {
  agent {
    kubernetes {
      label 'jenkins-dind'
      defaultContainer 'docker'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  securityContext:
    runAsUser: 0
  containers:
  - name: docker
    image: docker:24-cli
    command: ["sh","-c","sleep 365d"]
    tty: true
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    args:
    - --host=tcp://0.0.0.0:2375
    - --host=unix:///var/run/docker.sock
    - --tls=false
    - --storage-driver=overlay2
    - --mtu=1450
    volumeMounts:
    - name: dind-storage
      mountPath: /var/lib/docker
  volumes:
  - name: dind-storage
    emptyDir: {}
'''
    }
  }

  environment {
    GIT_URL     = 'https://github.com/Baluta-Lucian/conainters-SoD.git'
    GIT_BRANCH  = 'main'
    IMAGE       = "homework:${env.BUILD_NUMBER}"
    CONTAINER   = 'homework_container'
    PORT_MAP    = '8091:80'
    HEALTH_URL  = 'http://localhost:8091'
  }

  stages {
    stage('Clean dir') {
      steps { deleteDir() }
    }

    stage('Clone git repo') {
      steps {
        git branch: "${GIT_BRANCH}", url: "${GIT_URL}"
      }
    }

    stage('Wait for Docker daemon') {
      steps {
        container('docker') {
          sh '''
            set -euxo pipefail
            unset DOCKER_TLS_VERIFY DOCKER_CERT_PATH || true
            for i in $(seq 1 60); do
              if docker version >/dev/null 2>&1; then
                docker info | sed -n '1,20p'
                exit 0
              fi
              echo "Waiting for dockerd on ${DOCKER_HOST} ..."
              sleep 1
            done
            echo "dockerd did not become ready in time" >&2
            exit 1
          '''
        }
      }
    }

    stage('Build image') {
      steps {
        container('docker') {
          sh '''
            set -euxo pipefail
            unset DOCKER_TLS_VERIFY DOCKER_CERT_PATH || true
            docker build -t "${IMAGE}" .
          '''
        }
      }
    }

    stage('Run container') {
      steps {
        container('docker') {
          sh '''
            set -euxo pipefail
            unset DOCKER_TLS_VERIFY DOCKER_CERT_PATH || true
            docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
            docker run -d --name "${CONTAINER}" -p ${PORT_MAP} "${IMAGE}"
            echo "Container started on ${PORT_MAP}"

            for i in $(seq 1 60); do
              if curl -fsS "${HEALTH_URL}" >/dev/null 2>&1; then
                echo "Container is healthy"
                exit 0
              fi
              sleep 1
            done
            echo "Container failed to become healthy in time" >&2
            docker logs "${CONTAINER}" || true
            exit 1
          '''
        }
      }
    }

    stage('Test application') {
      steps {
        container('docker') {
          sh '''
            set -euxo pipefail
            unset DOCKER_TLS_VERIFY DOCKER_CERT_PATH || true
            code=$(curl -s -o /dev/null -w "%{http_code}" "${HEALTH_URL}")
            if [ "$code" -eq 200 ]; then
              echo "Application is running successfully!"
            else
              echo "Application test failed with status code: $code"
              docker logs "${CONTAINER}" || true
              exit 1
            fi
          '''
        }
      }
    }
  }

  post {
    always {
      container('docker') {
        sh '''
          set -eux
          unset DOCKER_TLS_VERIFY DOCKER_CERT_PATH || true
          docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" || true
          docker logs "${CONTAINER}" || true
          # uncomment to clean:
          # docker rm -f "${CONTAINER}" || true
        '''
      }
    }
  }
}
