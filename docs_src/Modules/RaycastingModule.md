# Raycasting module
Contains raycasting of the most basic shapes, implemented from
[Game Physics Cookbook](https://github.com/gszauer/GamePhysicsCookbook) by Gabor
Szauer. Does not serve as a replacement for more full-fledged solutions like
[ColMesh](https://marketplace.yoyogames.com/assets/8130/colmesh), but can be
used for smaller projects that do not require complex collision checking.

## Scripting API
<ul>
{% for v in modules_toc['Raycasting'] -%}
    <li><a href="{{ v['name'] }}.html">{{ v['name'] }}{{ v['tags'] }}</a></li>
{%- endfor %}
</ul>
