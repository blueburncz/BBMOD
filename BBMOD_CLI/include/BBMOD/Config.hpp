#pragma once

#include <BBMOD/common.hpp>

#include <assimp/matrix4x4.h>

/** A value used to tell that no normals should be generated
 * if the model doesn't have any. */
#define BBMOD_NORMALS_NONE 0

/** A value used to tell that flat normals should be generated
 * if the model doesn't have any. */
#define BBMOD_NORMALS_FLAT 1

/** A value used to tell that smooth normals should be generated
 * if the model doesn't have any. */
#define BBMOD_NORMALS_SMOOTH 2

/** BBANIM includes bone transforms in parent space. */
#define BBMOD_BONE_SPACE_PARENT (1 << 0)

/** BBANIM includes bone transforms in world space. */
#define BBMOD_BONE_SPACE_WORLD (1 << 1)

/** BBANIM includes bone transforms in bone spaces. */
#define BBMOD_BONE_SPACE_BONE (1 << 2)

/** Configuration structure. */
struct SConfig
{
	/** Convert data to left-handed. */
	bool LeftHanded = true;

	/** Invert vertex winding order. */
	bool InvertWinding = false;

	/** Disable saving vertex normals. This also automatically disable
	 * tangent vector and bitangent sign. */
	bool DisableNormals = false;

	/** Disable saving texture coordinates. */
	bool DisableTextureCoords = false;

	/** Disable saving of second texture coordinate layer. */
	bool DisableTextureCoords2 = true;

	/** Disable saving vertex colors. */
	bool DisableVertexColors = true;

	/** Disable saving tangent vector and bitangent sign. */
	bool DisableTangentW = false;

	/** Disable saving bones and animations. */
	bool DisableBones = false;

	/** Flip texture coordinates horizontally. */
	bool FlipTextureHorizontally = false;

	/** Flip texture coordinates vertically. */
	bool FlipTextureVertically = true;

	/** Flip normal vectors. */
	bool FlipNormals = false;

	/** Removes redundant/unreferenced materials. */
	bool OptimizeMaterials = true;

	/** Optimizes node hierarchy by joining multiple nodes into one. */
	bool OptimizeNodes = true;

	/** Reduces number of meshes. */
	bool OptimizeMeshes = true;

	/** Pre-transform vertices. */
	bool PreTransform = false;

	/** Apply scale defined in the model. */
	bool ApplyScale = false;

	/** Export materials to BBMAT files. (experimental) */
	bool ExportMaterials = false;

	/** Convert model from Y-up to Z-up. (experimental)  */
	bool ConvertToZUp = false;

	/** Prefix output files with model name. */
	bool Prefix = true;

	/**
	 * Configures generation of normal vectors.
	 * 
	 * @see BBMOD_NORMALS_NONE
	 * @see BBMOD_NORMALS_FLAT
	 * @see BBMOD_NORMALS_SMOOTH
	 */
	uint32_t GenNormals = BBMOD_NORMALS_SMOOTH;

	/** Rate (FPS) at which are the animations sampled. */
	double SamplingRate = 60.0;

	/**
	 * Animation optimization level.
	 * 
	 *   | Transitions | Attachments | IK
	 * - | ----------- | ----------- | ---
	 * 0 | Yes         | Yes         | Yes
	 * 1 | Yes         | Yes         | No
	 * 2 | No          | No          | No
	 */
	uint32_t AnimationOptimization = 0;
};
