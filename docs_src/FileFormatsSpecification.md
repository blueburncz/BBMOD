# File formats specification

## Types
* `SPACE_PARENT` - constant `0x1`
* `SPACE_WORLD` - constant `0x2`
* `SPACE_BONE` - constant `0x4`
* `Bool` - boolean value
* `u8` - unsigned byte, 8 bits
* `u32` - unsigned integer, 32 bits
* `f32` - floating-point value, 32 bits
* `f64` - double-precision floating-point value, 64 bits
* `String` - null-terminated string
* `Vec3` - x, y, z (3 x `f32`)
* `DualQuaternion` - rX, rY, rZ, rW, dX, dY, dZ, dW (8 x `f32`)
* `AnimationEvent` - frame (`f64`), name (`String`)
* `VertexFormat`
  * Vertices (`Bool`)
  * Normals (`Bool`)
  * TextureCoords (`Bool`)
  * TextureCoords2 (`Bool`)
  * Colors (`Bool`)
  * TangentW (`Bool`)
  * Bones (`Bool`)
  * Ids (`Bool`)
* `PrimitiveType`
  * constant `1` - point list
  * constant `2` - line list
  * constant `3` - line strip
  * constant `4` - triangle list
  * constant `5` - triangle strip
* `Mesh`
  * MaterialIndex (`u32`)
  * BboxMin (`Vec3`)
  * BboxMax (`Vec3`)
  * VertexFormat (`VertexFormat`)
  * PrimitiveType (`PrimitiveType`)
  * VertexCount (`u32`)
  * VertexBuffer (VertexCount x `bytesize(VertexFormat)`)
    * Position - x, y, z (3 x `f32`)
      * Present only when VertexFormat.Vertices is `true`!
    * Normal - x, y, z (3 x `f32`)
      * Present only when VertexFormat.Normals is `true`!
    * UV1 - u, v (2 x `f32`)
      * Present only when VertexFormat.TextureCoords is `true`!
    * UV2 - u, v (2 x `f32`)
      * Present only when VertexFormat.TextureCoords2 is `true`!
    * Color - argb (1 x `u32`)
      * Present only when VertexFormat.Colors is `true`!
    * TangentW - x, y, z, bitangentSign (4 x `f32`)
      * Present only when VertexFormat.TangentW is `true`!
    * BoneIndices - b1, b2, b3, b4 (4 x `f32`)
      * Present only when VertexFormat.Bones is `true`!
    * BoneWeights - w1, w2, w3, w4 (4 x `f32`)
      * Present only when VertexFormat.Bones is `true`!
    * InstanceId (`f32`)
      * Present only when VertexFormat.Ids is `true`!
* `Node`
  * Name (`String`)
  * Index (`String`)
  * IsBone (`Bool`)
  * Transform (`DualQuaternion`)
  * MeshCount (`u32`)
  * Meshes (MeshCount x `u32`)
  * ChildCount (`u32`)
  * Children (ChildCount x `Node`)

```gml
function bytesize(VertexFormat) {
    return (0
        + 12 * VertexFormat.Vertices
        + 12 * VertexFormat.Normals
        + 8 * VertexFormat.TextureCoords
        + 8 * VertexFormat.TextureCoords2
        + 4 * VertexFormat.Colors
        + 16 * VertexFormat.TangentW
        + 16 * VertexFormat.Bones
        + 4 * VertexFormat.Ids);
}
```

## BBMOD
* "BBMOD" (`String`)
* VersionMajor (`u8`)
  * Equals `3`
* VersionMinor (`u8`)
  * Equals `4`
* MeshCount (`u32`)
* Meshes (MeshCount x `Mesh`)
* NodeCount (`u32`)
* RootNode (`Node`)
* BoneCount (`u32`)
* Offsets (BoneCount x `DualQuaternion`)
* MaterialCount (`u32`)
* MaterialNames (MaterialCount x `String`)

## BBANIM
* "BBANIM" (`String`)
* VersionMajor (`u8`)
  * Equals `3`
* VersionMinor (`u8`)
  * Equals `4`
* Spaces (`u8`)
* Duration (`f64`)
* TicsPerSecond (`f64`)
* ModelNodeCount (`u32`)
* ModelBoneCount (`u32`)
* ParentSpaceFrames (ModelNodeCount x `DualQuaternion`)
  * Present only when `Spaces & SPACE_PARENT == 1`!
* WorldSpaceFrames (ModelNodeCount x `DualQuaternion`)
  * Present only when `Spaces & SPACE_WORLD == 1`!
* BoneSpaceFrames (ModelBoneCount x `DualQuaternion`)
  * Present only when `Spaces & SPACE_BONE == 1`!
* EventCount (`u32`)
* Events (EventCount x `AnimationEvent`)
