jeep = BBMOD_RESOURCE_MANAGER.load_sync("Data/Jeep/JeepBody.bbmod");
jeepTire = BBMOD_RESOURCE_MANAGER.load_sync("Data/Jeep/JeepTire.bbmod");

jeepX = -1.02;
jeepY = 0;
jeepZ = 0.75;
jeepScale = 0.01;

scale = 1;
collisionShape = undefined;
rigidBody = undefined;
vehicle = undefined;

steering = 0;

alarm[0] = 1;
