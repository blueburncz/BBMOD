var _terrain = global.terrain;
var _terrainPosition = _terrain.Position;
var _terrainSize = _terrain.Size;
var _terrainScale = _terrain.Scale;

x = _terrainPosition.X + clamp(x, 0, _terrainSize.X * _terrainScale.X);
y = _terrainPosition.Y + clamp(y, 0, _terrainSize.Y * _terrainScale.Y);
