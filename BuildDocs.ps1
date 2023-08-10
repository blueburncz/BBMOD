..\GMDoc\env\Scripts\activate
python.exe ..\GMDoc\gmdoc.py build
Remove-Item -Path C:\xampp\htdocs\bbmod\docs\3/*
Copy-Item -Path .\docs_build\* -Destination C:\xampp\htdocs\bbmod\docs\3 -Recurse
deactivate
