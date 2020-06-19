properties()
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hell World"'
                sh '''
                    echo "Multiline shell steps works too"
                    ls -lah
                '''
            }
        }
    }
}
