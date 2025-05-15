
# Phase 3: Group-Specific Idea

For the third phase our group plans on developing and implementing a video generation algorithm/model based on arbitrary text input.
The general idea is, we provide/pick some arbitrary text (e.g., lyrics from a song), that text input will be tokenized and an embedding (space?) will be generated (using clip). Then we will use those embeddings to find the most similar visual embedding in our opensearch index and extract the keyframe associated to that match.

We will repeat that proccess until there is association (keyframe-word) for every word of the text input.

Then we will proccess the text input again and iteratevely append the keyframes. In the end we should be left with a sequence of keyframes represents the text input visually.
That keyframe sequence will then be converted to a video (.mp4) file.

Possible extensions: (added complexity)

---
(professor suggestion)
Use a video generation model to create a small video (1-2 secs) given two adjacent frames. Repeat the proccess for all the frames.

Try to match the generated video with audio/music (on beat transitions?)

---

Use the generated video, run in through a caption generation model, and compare the generated caption with the initial text input. 
Or use the generated video to calculate the image caption similarity.



