CALL copy /y ..\major_maker_key.properties .\android
CALL copy /y ..\lfq.keystore .\android\app
CALL del /q /S ".\build\app\outputs\bundle\release\app-release.aab"
CALL flutter build appbundle --release
CALL cd .\build\app\outputs\bundle\release
CALL del /q /S "major-maker-release.aab"
CALL zipalign -v 4 app-release.aab major-maker-release.aab
CALL cd ..\..\..\..\.. 
CALL del /q /S "android\major_maker_key.properties"
CALL del /q /S "android\app\lfq.keystore"