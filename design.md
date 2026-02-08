# Intro

Designing a minecraft-like registry systems, for blocks and
block-states, not storing values of each property for each
state, instead finding the value of each property by just
looking at the ID

let's say a block have two properties:
```
const WATER_LOGGED = [true, false];
const FACING = ["x", "y", "z"];
```

total number of states: 2*3 = 6:

true, x
false, x
true, y
false, y
true, z
false, z

if we have the block-state ID, and ID of the first
block-state for this block, we can calculate
```
relative_id = block_state_id - first_block_state_id
```

if we divide this `relative_id` by `2` (cardinality of
`waterlogged`), we will get a number which we use to index
into the const array containing all values.

this design allows any ordering to be used, as long as it
is consistent, and block-state-ids are contiguous for a
given block
