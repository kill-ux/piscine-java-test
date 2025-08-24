#!/bin/bash

# Dynamic configuration
USERNAME="${USER:-muboutoub}"  # Default to 'muboutoub' if USER is not set
BASE_DIR="/home/$USERNAME"
PISCINE_JAVA_DIR="$PWD"
PISCINE_JAVA_TEST_DIR="$BASE_DIR/piscine-java-test"

# Ensure required environment variables are set
if [ -z "$EXERCISE" ]; then
    echo "Error: EXERCISE environment variable is not set"
    exit 1
fi

cd "$PISCINE_JAVA_TEST_DIR" || { echo "Error: Could not cd to $PISCINE_JAVA_TEST_DIR"; exit 1; }

set -e
if [ -d "project" ]; then
    rm -r project/src/main/java || { echo "Warning: Could not remove project/src/main/java"; }
else
    echo "Directory 'project' does not exist yet."
fi

mkdir -p project/src/main/java
mkdir -p project/src/test/java

# Support both variables CODE_EDITOR_RUN_ONLY and EXAM_RUN_ONLY
CODE_EDITOR_RUN_ONLY="${CODE_EDITOR_RUN_ONLY:-$EXAM_RUN_ONLY}"
# Support both variables CODE_EDITOR_MODE and EXAM_MODE
CODE_EDITOR_MODE="${CODE_EDITOR_MODE:-$EXAM_MODE}"

# Copy exercise files
if [ -z "$EDITOR_FILES" ]; then
    cp -rf "$PISCINE_JAVA_DIR/$EXERCISE/"*.java "$PISCINE_JAVA_TEST_DIR/project/src/main/java" || \
        { echo "Error: Could not copy exercise files"; exit 1; }
else
    cd "$PISCINE_JAVA_DIR" || { echo "Error: Could not cd to $PISCINE_JAVA_DIR"; exit 1; }
    cp -rf $(echo "$EDITOR_FILES" | tr ',' ' ') "$PISCINE_JAVA_TEST_DIR/project/src/main/java" || \
        { echo "Error: Could not copy specified editor files"; exit 1; }
    cd - > /dev/null
fi

cd "$PISCINE_JAVA_TEST_DIR" || { echo "Error: Could not cd to $PISCINE_JAVA_TEST_DIR"; exit 1; }

# Copy test files
cp -rf "./tests/StopAfterFailureExtension.java" "./project/src/main/java" || \
    { echo "Error: Could not copy StopAfterFailureExtension"; exit 1; }

cp -rf "./tests/${EXERCISE}_test"/*.java "./project/src/main/java" || \
    { echo "Error: Could not copy test files for $EXERCISE"; exit 1; }

cp ./pom.xml ./project || { echo "Error: Could not copy pom.xml"; exit 1; }

cd project || { echo "Error: Could not cd to project"; exit 1; }

# Compile and run tests
find -name "*.java" > sources.txt || { echo "Error: Could not find Java files"; exit 1; }

mvn compile -Dmaven.repo.local=./tests_utility \
            -Dmaven.compiler.include=@sources.txt exec:java \
            -Dexec.args="--details=tree --disable-banner --select-class ${EXERCISE}Test"