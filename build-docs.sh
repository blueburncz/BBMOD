source ../GMDoc/env/bin/activate

# Extract version from gmdoc.json
VERSION=$(python3 -c "import json; print(json.load(open('gmdoc.json'))['version'])")

python3 ../GMDoc/gmdoc.py build

# Create directory if it doesn't exist, then clean it
mkdir -p /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/${VERSION}
rm -rf /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/${VERSION}/*

cp -r docs_build/* /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/${VERSION}/

DB_SOURCE="./docs_build/docs.sqlite"
DB_DEST_DIR="/Applications/XAMPP/xamppfiles/htdocs/bbmod/data/docs"
DB_DEST="${DB_DEST_DIR}/docs-v${VERSION}.sqlite"

if [ -f "${DB_SOURCE}" ]; then
    mkdir -p "${DB_DEST_DIR}"
    cp "${DB_SOURCE}" "${DB_DEST}"
    echo "Copied SQLite database to ${DB_DEST}"
else
    echo "Warning: SQLite database not found at ${DB_SOURCE}" >&2
fi

deactivate
