source ../GMDoc/env/bin/activate
python3 ../GMDoc/gmdoc.py build 
rm -rf /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/3/*
cp -r docs_build/* /Applications/XAMPP/xamppfiles/htdocs/bbmod/docs/3/
deactivate
