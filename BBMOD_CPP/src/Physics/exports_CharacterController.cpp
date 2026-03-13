#include "PhysicsWorld.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#include <BulletDynamics/Character/btKinematicCharacterController.h>
#include <BulletCollision/CollisionDispatch/btGhostObject.h>
#include <BulletCollision/CollisionShapes/btCapsuleShape.h>

struct BBMOD_CharacterController
{
	btPairCachingGhostObject* m_ghostObject;
	btKinematicCharacterController* m_controller;
	btDynamicsWorld* m_world;

	BBMOD_CharacterController()
		: m_ghostObject(nullptr)
		, m_controller(nullptr)
		, m_world(nullptr)
	{
	}

	~BBMOD_CharacterController()
	{
		if (m_controller)
		{
			if (m_world)
			{
				m_world->removeAction(m_controller);
				m_world->removeCollisionObject(m_ghostObject);
			}
			delete m_controller;
			delete m_ghostObject->getCollisionShape();
			delete m_ghostObject;
		}
	}
};

////////////////////////////////////////////////////////////////////////////////
//
// Character Controller Creation
//

GM_EXPORT double BBMOD_PhysicsWorld_CreateCharacterController(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	// Read parameters from buffer
	auto radius = BBMOD_ReadBuffer<double>(_buffer);
	auto height = BBMOD_ReadBuffer<double>(_buffer);
	auto stepHeight = BBMOD_ReadBuffer<double>(_buffer);

	// Read initial position (vec3)
	btVector3 position;
	position.setX(BBMOD_ReadBuffer<double>(_buffer));
	position.setY(BBMOD_ReadBuffer<double>(_buffer));
	position.setZ(BBMOD_ReadBuffer<double>(_buffer));

	// Create character controller struct
	auto characterController = new BBMOD_CharacterController();
	characterController->m_world = physicsWorld->m_dynamicsWorld;

	// Create capsule shape (upright, Z-axis in Bullet)
	auto capsuleShape = new btCapsuleShapeZ(static_cast<btScalar>(radius), static_cast<btScalar>(height));

	// Create ghost object
	characterController->m_ghostObject = new btPairCachingGhostObject();
	characterController->m_ghostObject->setCollisionShape(capsuleShape);
	characterController->m_ghostObject->setCollisionFlags(btCollisionObject::CF_CHARACTER_OBJECT);

	btTransform startTransform;
	startTransform.setIdentity();
	startTransform.setOrigin(position);
	characterController->m_ghostObject->setWorldTransform(startTransform);

	// Create kinematic character controller
	characterController->m_controller = new btKinematicCharacterController(
		characterController->m_ghostObject,
		capsuleShape,
		static_cast<btScalar>(stepHeight),
		btVector3(0, 0, 1)  // Up axis is Z
	);

	// Add to world
	physicsWorld->m_dynamicsWorld->addCollisionObject(
		characterController->m_ghostObject,
		btBroadphaseProxy::CharacterFilter,
		btBroadphaseProxy::StaticFilter | btBroadphaseProxy::DefaultFilter
	);
	physicsWorld->m_dynamicsWorld->addAction(characterController->m_controller);

	// Register and return ID
	auto id = Registry::Add(characterController);
	return static_cast<double>(id);
}

////////////////////////////////////////////////////////////////////////////////
//
// Character Controller Movement
//

GM_EXPORT double BBMOD_CharacterController_SetWalkDirection(double _id, char* _buffer)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	btVector3 walkDirection;
	walkDirection.setX(BBMOD_ReadBuffer<double>(_buffer));
	walkDirection.setY(BBMOD_ReadBuffer<double>(_buffer));
	walkDirection.setZ(BBMOD_ReadBuffer<double>(_buffer));

	characterController->m_controller->setWalkDirection(walkDirection);
	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_SetVelocityForTimeInterval(double _id, char* _buffer, double _timeInterval)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	btVector3 velocity;
	velocity.setX(BBMOD_ReadBuffer<double>(_buffer));
	velocity.setY(BBMOD_ReadBuffer<double>(_buffer));
	velocity.setZ(BBMOD_ReadBuffer<double>(_buffer));

	characterController->m_controller->setVelocityForTimeInterval(velocity, static_cast<btScalar>(_timeInterval));
	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_ApplyPushForces(double _id, char* _buffer, double _pushStrength, double _pushRadius)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	// Read movement direction vector
	btVector3 moveDirection;
	moveDirection.setX(BBMOD_ReadBuffer<double>(_buffer));
	moveDirection.setY(BBMOD_ReadBuffer<double>(_buffer));
	moveDirection.setZ(BBMOD_ReadBuffer<double>(_buffer));

	// Skip if not moving
	if (moveDirection.length2() < 0.001)
	{
		return 0.0;
	}

	moveDirection.normalize();

	// Get character position
	btVector3 characterPos = characterController->m_ghostObject->getWorldTransform().getOrigin();

	// Get the world
	auto world = characterController->m_world;

	// Find all overlapping objects
	int numManifolds = world->getDispatcher()->getNumManifolds();
	int pushedCount = 0;

	for (int i = 0; i < numManifolds; i++)
	{
		btPersistentManifold* manifold = world->getDispatcher()->getManifoldByIndexInternal(i);

		const btCollisionObject* objA = manifold->getBody0();
		const btCollisionObject* objB = manifold->getBody1();

		// Check if one of the objects is our ghost object
		const btCollisionObject* otherObj = nullptr;
		if (objA == characterController->m_ghostObject)
		{
			otherObj = objB;
		}
		else if (objB == characterController->m_ghostObject)
		{
			otherObj = objA;
		}
		else
		{
			continue; // Not our collision
		}

		// Only push dynamic rigid bodies
		const btRigidBody* rigidBody = btRigidBody::upcast(otherObj);
		if (!rigidBody || rigidBody->isStaticOrKinematicObject())
		{
			continue;
		}

		// Get object position
		btVector3 objPos = otherObj->getWorldTransform().getOrigin();

		// Check if within push radius
		btVector3 toObject = objPos - characterPos;
		btScalar distance = toObject.length();

		if (distance > static_cast<btScalar>(_pushRadius) || distance < 0.001)
		{
			continue;
		}

		// Calculate push direction (combination of movement direction and direction to object)
		btVector3 pushDir = moveDirection * 0.7 + toObject.normalized() * 0.3;
		pushDir.normalize();

		// Calculate push force (stronger when closer)
		btScalar falloff = 1.0 - (distance / static_cast<btScalar>(_pushRadius));
		btScalar forceMagnitude = static_cast<btScalar>(_pushStrength) * falloff;

		// Apply the push force at the object's center of mass
		btVector3 pushForce = pushDir * forceMagnitude;
		const_cast<btRigidBody*>(rigidBody)->applyCentralForce(pushForce);

		pushedCount++;
	}

	return static_cast<double>(pushedCount);
}

////////////////////////////////////////////////////////////////////////////////
//
// Character Controller State
//

GM_EXPORT double BBMOD_CharacterController_IsOnGround(double _id)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	return characterController->m_controller->onGround() ? 1.0 : 0.0;
}

GM_EXPORT double BBMOD_CharacterController_Jump(double _id, char* _buffer)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	// Read optional jump velocity (vec3)
	btVector3 jumpVelocity;
	jumpVelocity.setX(BBMOD_ReadBuffer<double>(_buffer));
	jumpVelocity.setY(BBMOD_ReadBuffer<double>(_buffer));
	jumpVelocity.setZ(BBMOD_ReadBuffer<double>(_buffer));

	characterController->m_controller->jump(jumpVelocity);
	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Character Controller Properties
//

GM_EXPORT double BBMOD_CharacterController_SetFallSpeed(double _id, double _speed)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	characterController->m_controller->setFallSpeed(static_cast<btScalar>(_speed));
	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_SetJumpSpeed(double _id, double _speed)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	characterController->m_controller->setJumpSpeed(static_cast<btScalar>(_speed));
	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_SetMaxSlope(double _id, double _radians)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	characterController->m_controller->setMaxSlope(static_cast<btScalar>(_radians));
	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_SetStepHeight(double _id, double _height)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	characterController->m_controller->setStepHeight(static_cast<btScalar>(_height));
	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_SetGravity(double _id, char* _buffer)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	btVector3 gravity;
	gravity.setX(BBMOD_ReadBuffer<double>(_buffer));
	gravity.setY(BBMOD_ReadBuffer<double>(_buffer));
	gravity.setZ(BBMOD_ReadBuffer<double>(_buffer));

	characterController->m_controller->setGravity(gravity);
	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_SetUseGhostObjectSweepTest(double _id, double _enable)
{
	// Note: In Bullet 3, the ghost object sweep test is always enabled for
	// btKinematicCharacterController. The setUseGhostObjectSweepTest() method
	// doesn't exist in Bullet 3. This function is kept as a no-op for API
	// compatibility.
	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Character Controller Crouching / Height
//

GM_EXPORT double BBMOD_CharacterController_SetCapsuleHeight(double _id, double _newHeight)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	// Get current capsule shape
	auto currentShape = static_cast<btCapsuleShapeZ*>(characterController->m_ghostObject->getCollisionShape());
	auto radius = currentShape->getRadius();

	// Create new capsule with same radius but new height
	auto newShape = new btCapsuleShapeZ(radius, static_cast<btScalar>(_newHeight));

	// Replace shape
	characterController->m_ghostObject->setCollisionShape(newShape);

	// Clean up old shape
	delete currentShape;

	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_GetCapsuleHeight(double _id)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	auto capsuleShape = static_cast<btCapsuleShapeZ*>(characterController->m_ghostObject->getCollisionShape());
	return static_cast<double>(capsuleShape->getHalfHeight() * 2.0);
}

GM_EXPORT double BBMOD_CharacterController_GetCapsuleRadius(double _id)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	auto capsuleShape = static_cast<btCapsuleShapeZ*>(characterController->m_ghostObject->getCollisionShape());
	return static_cast<double>(capsuleShape->getRadius());
}

////////////////////////////////////////////////////////////////////////////////
//
// Character Controller Position
//

GM_EXPORT double BBMOD_CharacterController_GetPosition(double _id, char* _buffer)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	btTransform transform = characterController->m_ghostObject->getWorldTransform();
	btVector3 position = transform.getOrigin();

	BBMOD_WriteBuffer(_buffer, position.x());
	BBMOD_WriteBuffer(_buffer, position.y());
	BBMOD_WriteBuffer(_buffer, position.z());

	return 1.0;
}

GM_EXPORT double BBMOD_CharacterController_SetPosition(double _id, char* _buffer)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);

	btVector3 position;
	position.setX(BBMOD_ReadBuffer<double>(_buffer));
	position.setY(BBMOD_ReadBuffer<double>(_buffer));
	position.setZ(BBMOD_ReadBuffer<double>(_buffer));

	btTransform transform = characterController->m_ghostObject->getWorldTransform();
	transform.setOrigin(position);
	characterController->m_ghostObject->setWorldTransform(transform);

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Character Controller Cleanup
//

GM_EXPORT double BBMOD_CharacterController_Destroy(double _id)
{
	auto characterController = Registry::Get<BBMOD_CharacterController>(_id);
	Registry::Remove(_id);
	delete characterController;
	return 1.0;
}
