event_inherited();

physicsEngine = new BBMOD_PhysicsEngine();

var _worldInfo = new BBMOD_PhysicsWorldInfo();
_worldInfo.DebugMode = (0
	| btDebugDrawModes.DBG_DrawWireframe
	| btDebugDrawModes.DBG_FastWireframe
	| btDebugDrawModes.DBG_DrawConstraints
	| btDebugDrawModes.DBG_DrawConstraintLimits
	| btDebugDrawModes.DBG_DrawFrames
);
physicsWorld = physicsEngine.create_physics_world(_worldInfo);

physicsTerrain = physicsWorld.create_terrain(terrain);

physicsDebug = false;
physicsPause = false;
