source ../GMDoc/env/bin/activate

# Extract version from gmdoc.json
VERSION=$(python3 -c "import json; print(json.load(open('gmdoc.json'))['version'])")

python3 ../GMDoc/gmdoc.py build

# Create directory if it doesn't exist, then clean it
mkdir -p /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/${VERSION}
rm -rf /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/${VERSION}/*

cp -r docs_build/* /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/${VERSION}/
deactivate
