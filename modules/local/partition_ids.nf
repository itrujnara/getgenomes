process PARTITION_IDS {
    tag "$meta.id"
    label "process_single"

    conda "conda-forge::coreutils=9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/c2/c262fc09eca59edb5a724080eeceb00fb06396f510aefb229c2d2c6897e63975/data' :
        'community.wave.seqera.io/library/coreutils:9.5--ae99c88a9b28c264' }"

    input:
    tuple val(meta), path(ids)

    output:
    tuple val(meta), path("*_chunk_*.txt"), emit: chunks
    path "versions.yml"                   , emit: versions

    script:
    prefix = task.ext.prefix ? task.ext.prefix : meta.id
    """
    #!/bin/bash

    # Split the IDs file into chunks
    split -d -l 10 ${ids} ${prefix}_chunk_ --additional-suffix=.txt

    # Print the software versions
    cat <<- END_VERSIONS > versions.yml
    "$task.process":
        split --version | head -1 | cut -d ' ' -f 4
    END_VERSIONS
    """

    stub:
    """
    #!/bin/bash

    touch ${prefix}_chunk_00.txt

    # Print the software versions
    cat <<- END_VERSIONS > versions.yml
    "$task.process":
        split --version | head -1 | cut -d ' ' -f 4
    END_VERSIONS
    """
}
