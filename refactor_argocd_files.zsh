#!/bin/zsh

setopt EXTENDED_GLOB
setopt VERBOSE

for yamlfile in `find . -name "*.yaml" -a \! -name "kustomization.yaml"` ; do
    name=`yq '.metadata.name' ${yamlfile}`
    kind=`yq '.kind' ${yamlfile}`
    dir=`dirname ${yamlfile}`
    mv ${yamlfile} ${dir}/${kind}_${name}.yaml
done

for kustfile in */kustomization.yaml ; do
    dir=`dirname ${kustfile}`
    otherfiles=`ls ./${dir}/*~*/kustomization.yaml`
    yq -i '.resources = []' ${dir}/kustomization.yaml
    for otherfile in "${otherfiles}" ; do
        yamlfile=`filename ${otherfile}`
        yq -i '.resources += "'${yamlfile}'"' ${dir}/kustomization.yaml
    done
done
