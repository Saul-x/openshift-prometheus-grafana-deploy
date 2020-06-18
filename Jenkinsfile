properties([opalCollector()])
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                s 'echo "Hello World"'
                sh '''
                    echo "Multiline shell steps works too"
                    ls -lah
                '''
            }
        }
    }
}
