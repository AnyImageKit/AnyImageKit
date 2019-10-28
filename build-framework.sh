#!/bin/bash

projectName=""

deleteCarthage() {
    rm -r Carthage
}

build() {
    carthage build --no-skip-current --configuration "Release" --platform all
}

getProjectName() {
    for file in `ls $1`
    do
        if [[ ${file##*.} == "xcodeproj" ]] ; then
            projectName=${file%%.*}
        fi
    done
}

zipFramework() {
    getProjectName
    zip -r "$projectName.framework.zip" Carthage
}

# Main

deleteCarthage
build
zipFramework
