#!/bin/sh

set -e
if [ -d "project" ]; then
    rm -r project/src/main/java
else
    echo "Directory 'project' does not exist yet."
fi

mkdir -p project/src/main/java
mkdir -p project/src/test/java

# ! support both variables CODE_EDITOR_RUN_ONLY and EXAM_RUN_ONLY
CODE_EDITOR_RUN_ONLY="${CODE_EDITOR_RUN_ONLY:-$EXAM_RUN_ONLY}"
# ! support both variables CODE_EDITOR_MODE and EXAM_MODE
CODE_EDITOR_MODE="${CODE_EDITOR_MODE:-$EXAM_MODE}"


if [ -z "$EDITOR_FILES" ]; then
    cp -rf "/home/muboutoub/piscine-java/${EXERCISE}/"*.java /home/muboutoub/piscine-java-test/project/src/main/java
else
    cd /home/muboutoub/piscine-java/
    cp -rf $(echo $EDITOR_FILES | tr ',' ' ') /home/muboutoub/piscine-java-test/project/src/main/java
    cd -
fi

cd /home/muboutoub/piscine-java-test

cp -rf "./tests/StopAfterFailureExtension.java" ./project/src/main/java

cp -rf "./tests/${EXERCISE}_test"/*.java ./project/src/main/java

cp ./pom.xml ./project

cd project

find -name "*.java" > sources.txt

mvn compile -Dmaven.repo.local=./tests_utility \
            -Dmaven.compiler.include=@sources.txt exec:java \
            -Dexec.args="--details=tree --disable-banner --select-class ${EXERCISE}Test"
