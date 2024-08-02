new BBMOD_Matrix()
	.Scale(1000, 1000, 1000)
	.Translate(camera.Position)
	.ApplyWorld();
modSphere.render([matSky]);

// Enqueue scene rendering commands
scene.render();

/*
// Create sprite material
var _matSprite = BBMOD_MATERIAL_DEFERRED.clone();
_matSprite.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
_matSprite.NormalSmoothness = sprite_get_texture(Sprite18, current_time * 0.001);
_matSprite.Culling = cull_noculling;

// Draw sprite
var _queue = bbmod_render_queue_get_default();
_queue.ApplyMaterial(_matSprite, BBMOD_VFORMAT_DEFAULT_SPRITE);
_queue.BeginConditionalBlock();
	_queue.SetWorldMatrix(matrix_build(20, 0, 7, 90, 0, current_time * 0.05, 0.1, 0.1, 0.1));
	_queue.DrawSprite(Sprite17, current_time * 0.001, -32, 0);
	_queue.ResetMaterial();
_queue.EndConditionalBlock();
*/

// Reset world matrix to identity
BBMOD_MATRIX_IDENTITY.ApplyWorld();

// Actually render scene
renderer.render();

/*
// Destroy temporary sprite material
_matSprite.destroy();
*/
