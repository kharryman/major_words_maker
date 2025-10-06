CALL taskkill /F /IM java.exe /T
CALL taskkill /F /IM gradle.exe /T
CALL flutter clean
CALL flutter pub get
CALL copy /y ..\flutter_key.properties .\android
CALL copy /y ..\lfq.keystore .\android\app
CALL del /q /S ".\build\app\outputs\bundle\release\app-release.aab"
CALL flutter build appbundle --release
CALL cd .\build\app\outputs\bundle\release
CALL del /q /S "major-words-maker-release.aab"
CALL zipalign -v 4 app-release.aab major-words-maker-release.aab
CALL cd ..\..\..\..\.. 
CALL del /q /S "android\flutter_key.properties"
CALL del /q /S "android\app\lfq.keystore"
CALL node node_trans_release_notes.js
CALL cd .\android
CALL bundle exec fastlane deploy
CALL cd ..
@ECHO OFF