#!/bin/zsh
# set -x
# Check if we need to compile with the JAR file
jar_files=(*[bB]/*.jar)
if [ "${#jar_files[@]}" -ge 1 ]; then
  echo "Found JAR files. Compiling Java source files with JAR dependencies..."
  javac -cp "${jar_files[@]}" ./*[bB]/*.java
  else
    echo "No JAR files provided. Compiling Java source..."
    javac ./*[bB]/*.java
fi

for file in *[bB]/*.class; do
  # Extract the directory and the class name
  dir=$(dirname "$file")
  classname=$(basename "$file" .class)

  # Look for a class with main method
  if javap -cp "$dir" -public "$classname" | grep -q 'public static void main(java.lang.String\[\]);'; then
    echo "Found main method in $classname from directory $dir..."
    if [ "${#jar_files[@]}" -ge 1 ]; then
      echo "Running with provided JAR file..."
      java -cp "$dir:${jar_files[*]}" "$classname" < pb_stdin.txt > a.txt
    else
      echo "Running..."
      java -cp "$dir" "$classname" < pb_stdin.txt > a.txt
    fi

    # Open in vimdiff and delete stdout file
    vimdiff -c "set diffopt+=iwhiteall" a.txt pb_stdout.txt
    rm a.txt
  fi
done
