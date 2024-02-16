CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area
rm -rf git-clone-output.txt

mkdir grading-area

git clone $1 student-submission 2> git-clone-output.txt
echo 'Finished cloning'


# Draw a picture/take notes on the directory structure that's set up after
# getting to this point

# Then, add here code to compile and run, and do any post-processing of the
# tests

if [ -f "student-submission/ListExamples.java" ]; then
    echo "File found!"
else
    echo "ListExamples.java not found"
    exit 1
fi

# jars
cp -r lib grading-area
# ListExamples
cp student-submission/ListExamples.java grading-area/
# TestListExamples
cp TestListExamples.java grading-area

cd grading-area
javac -cp $CPATH *.java

if [ $? -ne 0 ]; then
    echo "Compile Error"
    exit 1
else
    echo "Compiles Successfully!"
fi


if grep -q "OK" <<< $(java -cp $CPATH org.junit.runner.JUnitCore TestListExamples) ; then
    echo "You passed all tests. Good Job!"
    echo "Grade: 100%"
else 
    RESULTS=$(java -cp $CPATH org.junit.runner.JUnitCore TestListExamples | grep "Tests run:" )
    TESTSRUN=$(echo $RESULTS | cut -d',' -f1)
    FAILURES=$(echo $RESULTS | cut -d',' -f2)

    NUMTESTS=$(echo $TESTSRUN | cut -d':' -f2)
    NUMFAILURES=$(echo $FAILURES | cut -d':' -f2)

    NUMTESTS=${NUMTESTS// /}
    NUMFAILURES=${NUMFAILURES// /}

    NUMPASSED=$(expr $NUMTESTS - $NUMFAILURES)
    GRADE=$(echo "scale=2; $NUMPASSED / $NUMTESTS * 100" | bc)

    echo "You passed $NUMPASSED out of $NUMTESTS. Try Again!"
    echo "GRADE: $GRADE%"
fi