@ECHO OFF

REM START NODE-RED
REM start cmd /c cd .\node-red ^& call "node-red_run.bat"

REM START JACAMO
start cmd /c cd .\jacamo ^& gradlew clean compileJava copyToLib ^& mas_run.bat

REM start cmd /c gradlew clean compileJava copyToLib ^& docker build -t agbr/u5:0.1 .
