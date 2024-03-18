#!/usr/bin/env nextflow

params.file = "$projectDir/hello/hello.txt"
//params.greeting = 'Hello world!'
greeting_ch = Channel.fromPath(params.file)
params.outdir = "$params.outdir/results_test"
println "projectDir: $projectDir"

process SPLITLETTERS {
    //container "nextflow/examples:latest"

    input:
    path x

    output:
    path 'helloSplit_*'

    """
    head -1 ${x} | split -b 6 - helloSplit_
    """
}

process CONVERTTOUPPER {
    //container "nextflow/examples:latest"
    publishDir "${params.outdir}/results_test", mode:'copy'
    input:
    path y

    output:
    path 'helloSplitUppercase.txt'

    """
    head -1 ${y} | tr '[a-z]' '[A-Z]' >> helloSplitUppercase.txt
    """
}

workflow {
    letters_ch = SPLITLETTERS(greeting_ch)
    results_ch = CONVERTTOUPPER(letters_ch.flatten())
    results_ch.view{ it }
}
