process FETCH_GENOMES {
    tag "$meta.id"
    label "process_single"

    conda "conda-forge::curl=8.10.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/5f/5f0edcb035b00982b0f00d0d0bfe4f69bdc1ad97de9fdcad0176993689f6c6bc/data' :
        'community.wave.seqera.io/library/curl:8.10.1--43150f2d543ef413' }"

    input:
    tuple val(meta), path(ids)
    val base_url

    output:
    tuple val(meta), path("*/*.fasta.gz"), emit: genomes
    path "versions.yml"                  , emit: versions

    script:
    prefix = task.ext.prefix ? task.ext.prefix : meta.id
    """
    #!/bin/bash

    # Fetch the genomes
    for id in \$(cat ${ids}); do
        id_suffix=\$(echo \${id} | awk -F'_' '{print \$NF}')
        mkdir -p \${id}
        curl -sSL ${base_url}/\${id}/\${id_suffix}.genome.fasta.gz -o \${id}/\${id_suffix}.fasta.gz
    done

    # Print the software versions
    cat <<- END_VERSIONS > versions.yml
    "$task.process":
        curl --version | head -1 | cut -d ' ' -f 2
    END_VERSIONS
    """

    stub:
    """
    #!/bin/bash

    touch ${prefix}.fasta.gz

    # Print the software versions
    cat <<- END_VERSIONS > versions.yml
    "$task.process":
        curl --version | head -1 | cut -d ' ' -f 2
    END_VERSIONS
    """
}
