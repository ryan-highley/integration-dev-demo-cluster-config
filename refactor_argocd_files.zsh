#!/bin/zsh

setopt EXTENDED_GLOB
setopt VERBOSE

for kustfile in `find . -name kustomization.yaml` ; do
    dir=`dirname ${kustfile}`
    echo Processing ${dir}...
    pushd ${dir}
    for otherfile in `ls ^kustomization.yaml` ; do
        name=`yq '.metadata.name' ${otherfile}`
        kind=`yq '.kind' ${otherfile}`
        yamlfile="${kind}_${name}.yaml"
        echo Processing ${otherfile} with kind: ${kind} and name: ${name} \(Renaming ${otherfile} to ${yamlfile}\)
        mv ${otherfile} ${yamlfile}
        yq -i '(.resources[] | select(. == "'${otherfile}'")) = "'${yamlfile}'"' kustomization.yaml
    done
    popd
done
