..\GMDoc\env\Scripts\activate

# Extract version from gmdoc.json
$VERSION = (Get-Content gmdoc.json | ConvertFrom-Json).version

python.exe ..\GMDoc\gmdoc.py build

# Create directory if it doesn't exist, then clean it
New-Item -ItemType Directory -Path C:\xampp\htdocs\bbmod\docs\$VERSION -Force | Out-Null
Remove-Item -Path C:\xampp\htdocs\bbmod\docs\$VERSION\* -Recurse -Force -ErrorAction SilentlyContinue

Copy-Item -Path .\docs_build\* -Destination C:\xampp\htdocs\bbmod\docs\$VERSION -Recurse

$DB_SOURCE = ".\docs_build\docs.sqlite"
$DB_DEST_DIR = "C:\xampp\htdocs\bbmod\data\docs"
$DB_DEST = "$DB_DEST_DIR\docs-v$VERSION.sqlite"

if (Test-Path $DB_SOURCE)
{
    New-Item -ItemType Directory -Path $DB_DEST_DIR -Force | Out-Null
    Copy-Item -Path $DB_SOURCE -Destination $DB_DEST -Force
    Write-Host "Copied SQLite database to $DB_DEST"
}
else
{
    Write-Warning "SQLite database not found at $DB_SOURCE"
}

deactivate
