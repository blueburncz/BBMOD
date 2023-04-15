# OBJ importer module
Using this module you can load OBJ models without converting them to BBMOD first.
This is especially handy during development, as it allows for faster iterations,
but for production you should aim to use BBMOD files, because they are faster to
load an they take less disk space compared to OBJ.

## Scripting API
<ul>
{% for v in modules_toc['OBJImporter'] -%}
    <li><a href="{{ v['name'] }}.html">{{ v['name'] }}{{ v['tags'] }}</a></li>
{%- endfor %}
</ul>
