event_inherited();

model = new BBMOD_Model("Data/BBMOD/Models/Sphere.bbmod").freeze();

material = BBMOD_MATERIAL_DEFAULT.clone()
	.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID);
material.BaseOpacityMultiplier = new BBMOD_Color().FromHSV(random(255), 100, 100);
model.Materials[0] = material;

rotation = new BBMOD_Vec3();

scale = new BBMOD_Vec3(10.0);
