#!/usr/bin/env nextflow

params.file = "$projectDir/hello/hello.txt"
//params.greeting = 'Hello world!'
//greeting_ch = Channel.fromPath(params.file)
params.outdir = "az://biosustaindls/development/results"
//println "projectDir: $projectDir"

//Read Azure storage credentials from credentials.json
def azureCredentials = new JsonSlurper().parseText(new File("./credentials_test.json").text)
def storageAccountName = azureCredentials.biosustaindls.storageAccountName
def eventHubsConnectionString = azureCredentials.biosustaindls.eventGridEndpoint


//define a channel to read events from Azure Event Hub
eventHubChannel = Channel.fromEventHub("testone")

process SPLITLETTERS {
    //container "nextflow/examples:latest"
    
    input:
    path x from eventHubChannel

    output:
    path 'helloSplit_*'

    """
    az storage blob download -n \${x} -c development --account-name ${storageAccountName}
    
    head -1 ${x} | split -b 6 - results/helloSplit_
    """
}

process CONVERTTOUPPER {
    //container "nextflow/examples:latest"
    publishDir "az://biosustaindls/development/results", mode:'copy'

    input:
    path y

    output:
    path 'results/helloSplitUppercase.txt'

    """
    head -1 ${y} | tr '[a-z]' '[A-Z]' >> helloSplitUppercase.txt 
    """
}

workflow {
    greetinh_ch =Channel.fromPath(params.file)
    letters_ch = SPLITLETTERS(greeting_ch)
    results_ch = CONVERTTOUPPER(letters_ch.flatten())
    results_ch.view{ it }
}
report {
    // Print completion message to console
    println "Pipeline execution completed successfully!"
}


