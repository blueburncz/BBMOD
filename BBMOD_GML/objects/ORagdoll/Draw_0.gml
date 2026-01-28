if (Ragdoll[0].RigidBody == undefined) exit;
bbmod_set_instance_id(id);
//new BBMOD_Matrix().Scale(5, 5, 5).ApplyWorld();
GetTransformArray(transformArray);
model.render(undefined, transformArray);
bbmod_set_instance_id(0);
