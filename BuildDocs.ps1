..\GMDoc\env\Scripts\activate

# Extract version from gmdoc.json
$VERSION = (Get-Content gmdoc.json | ConvertFrom-Json).version

python.exe ..\GMDoc\gmdoc.py build

# Create directory if it doesn't exist, then clean it
New-Item -ItemType Directory -Path C:\xampp\htdocs\bbmod\docs\$VERSION -Force | Out-Null
Remove-Item -Path C:\xampp\htdocs\bbmod\docs\$VERSION\* -Recurse -Force -ErrorAction SilentlyContinue

Copy-Item -Path .\docs_build\* -Destination C:\xampp\htdocs\bbmod\docs\$VERSION -Recurse
deactivate
