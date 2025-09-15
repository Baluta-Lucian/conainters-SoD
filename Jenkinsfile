pipeline {
    agent dockerContainer('docker:20.10.16-dind') {
        args '-v /var/run/docker.sock:/var/run/docker.sock'
    }

    environment {
        DOCKER_HOST = 'tcp://localhost:2375'
        DOCKER_TLS_VERIFY = '0'
    }

    stages {
        stage('Clean dir') {
            steps {
                deleteDir()
            }
        }
        stage('clone git repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Baluta-Lucian/conainters-SoD.git'
            }
        }
        stage('Setup Container') {
            steps {
                sh '''
                    echo "Setting up container..."
                    docker build -t homework:${BUILD_NUMBER} .
                    docker ps | grep homework_container && docker stop homework_container && docker rm homework_container || echo "No existing container to remove"
                    docker run -d -p 8091:80 --name homework_container homework:${BUILD_NUMBER}
                    echo "Container is up and running on port 8091"
                '''
            }
        }
        stage('Test Application') {
            steps {
                sh '''
                    echo "Testing application..."
                    sleep 10  # Wait for the container to be fully up
                    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8091)
                    if [ "$response" -eq 200 ]; then
                        echo "Application is running successfully!"
                    else
                        echo "Application test failed with status code: $response"
                        exit 1
                    fi
                '''
            }
        }
    // stage('Cleanup') {
    //     steps {
    //         sh '''
    //             echo "Cleaning up..."
    //             docker stop homework_container
    //             docker rm homework_container
    //             docker rmi homework:${BUILD_NUMBER}
    //             echo "Cleanup completed."
    //         '''
    //     }
    // }
    }
}
