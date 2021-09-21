# Animation optimization levels
When converting an animated model to BBMOD, you can choose an optimization level
you would like to use for its animations. The higher the optimization level is,
the less computation has to be done in GameMaker to find bones' final position,
which is then passed to shaders. This also comes with restrictions of what you
can do with the animations that use higher optimization levels.

## Table of optimization levels

Level | Transformations are stored in | Transform bones in GML | Bone attachments | Animation transitions
----- | ----- | ---------------------- | ---------------- | ---------------------
`0` | Parent-space | Yes | Yes | Yes
`1` | World-space | No | Yes | Yes
`2` | Bone-space | No | No | No


Use argument `--optimize-animations` (`-oa`) in BBMOD CLI to configure the
animation optimization level.

## Bone transformation spaces
### Parent-space
When bone transformations are in parent-space, it means that each bone's
transform is relative to its parent bone. To retrieve the final position of such
bone, we have to traverse all bones from the root to the current one and
accumulate their transforms: `offset * bone * (parent1 * ... * parentN) * root`.
The benefit of this is that transformations of individual bones can be modified
on runtime in GML, which can be used for example for inverse kinematics. On the
downside, for models with a lot of bones (or for a lot of models with just a few
bones) this is very expensive operation which would have a negative effect on
your game's performance.

You should choose this space only for models which absolutely need to modify bone
transformations in GML.

### World-space
When bone transformations are in world-space, it means that a bone's parent
transformation is already factored in. To retrieve the final position of such
bone, all we have to do is multiply its transform with its offset:
`offset * bone`. Compared to parent-space, this saves a lot of computation.
Since the bones are in world-space, their transformation can still be retrieved
with [get_node_transform](./BBMOD_AnimationPlayer.get_node_transform.html) and
used for attachments.

If your model does not require inverse kinematics or similar techniques, this
space is a great performance boost and a great choice for your game.

### Bone-space
When bone transformations are in bone-space, it means that even their offset is
already factored in and they are ready to be sent to shaders. Playback of
animations using bone-space transforms is super fast - it is just a lookup into
an array. One the downside, this also comes with the most restrictions - you
cannot change bone transforms in GML, you cannot use bone transformations for
attachments and the animation player can no longer make interpolated transitions
into and out of the animation.

In practice, this is still extremely usable, but requires more attention on the
art side. For example, if your game has an enemy who can wield one of three
weapons, you could include them in the enemy's model and use `BBMOD_Node`'s
[Visible](./BBMOD_Node.Visible.html) property to show only one of them instead
of using attachments. Instead of relying on interpolated transitions, you could
design your animations in such ways that change between them is not so abrupt
and less noticeable. Or maybe you are working on a game where the lack of
transitions fits the art-style and then you do not need to worry about it.

Generally speaking, this space is the best choice for your game's performance,
but the game's assets will require special attention to make it work and look
good.

## Which one to choose?
We have all heard that premature optimization is the root of all evil, so we
suggest you choose the least restrictive optimization level you can use and
start from there. I.e. if you know that you do not need inverse kinematics, just
use level 1 for everything and later on, when your game is getting closer to
release, if the fps are not high enough, think about which assets could use
level 2. You can choose different levels for different assets and find the right
configuration for your game as it develops.
