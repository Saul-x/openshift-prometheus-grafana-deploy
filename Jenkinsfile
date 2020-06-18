properties([opalCollector()])
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'cho "Hello World"'
                sh '''
                    echo "Multiline shell steps works too"
                    ls -lah
                '''
            }
        }
    }
}
