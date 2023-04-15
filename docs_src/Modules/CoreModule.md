# Core module
This is the only module that you need to import into your project to be able
to use BBMOD. It contains code essential for loading models and animations,
animation playback, basic rendering, batching models for increased rendering
performance, as well as a math library for easier manipulation with vectors,
quaternions etc.

## Scripting API
<ul>
{% for v in modules_toc['Core'] -%}
    <li><a href="{{ v['name'] }}.html">{{ v['name'] }}{{ v['tags'] }}</a></li>
{%- endfor %}
</ul>
