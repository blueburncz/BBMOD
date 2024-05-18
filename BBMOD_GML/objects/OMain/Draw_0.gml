new BBMOD_Matrix()
	.Scale(1000, 1000, 1000)
	.Translate(camera.Position)
	.ApplyWorld();
modSphere.render([matSky]);

new BBMOD_Matrix()
	.Translate(0, 0, 1)
	.ApplyWorld();
modSphere.render([matSphere]);

terrain.render();

var _matSprite = BBMOD_MATERIAL_DEFERRED.clone();
_matSprite.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
_matSprite.Culling = cull_noculling;

var _queue = bbmod_render_queue_get_default();
_queue.ApplyMaterial(_matSprite, BBMOD_VFORMAT_DEFAULT_SPRITE);
_queue.BeginConditionalBlock();
	_queue.SetWorldMatrix(matrix_build(10, 0, 0, 0, 90, 0, 0.1, 0.1, 0.1));
	_queue.DrawSprite(Sprite17, 0, 0, 0);
_queue.EndConditionalBlock();

BBMOD_MATRIX_IDENTITY.ApplyWorld();
camera.apply();
renderer.render();

_matSprite.destroy();
