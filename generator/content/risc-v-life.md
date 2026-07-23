---
title: "RISC-V Conway's Game of Life"
slug: "risc-v-life"
index: "004"
status: "published"
date: "2026-04-27"
category: "ALGO"
thought: "Complex patterns can emerge from only a few rules. Rebuilding that idea in assembly makes every small decision feel visible."
---

Conway's Game of Life is an animated cellular automaton that models a simple environment of scarcity, survival, and competition. This implementation was written in RISC-V assembly and designed to run in [RARS](https://github.com/thethirdone/rars).

## Links
* **Repo:** [RISC-V Game of Life source](https://github.com/ElliotDomino/sequestered.space/tree/7ef2afa5bb207c169e27be196d9f2c777e2cb859/projects/risc-v-life)

## The Project
I was first introduced to RISC-V and RARS through a university class. RISC-V is an instruction-set architecture that can be simulated on conventional hardware using tools such as RARS.

Working with RISC-V was initially difficult because it was my first real experience writing assembly. With practice, however, I began to enjoy the directness of the language and the way it exposes the smaller operations behind a program.

This project implements [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) by interacting with the Bitmap Display tool included with RARS. Each cell changes from one generation to the next according to a small set of rules, producing surprisingly complex patterns over time.

<video controls>
  <source src="./resources/demo.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Context
This project was an excuse to do more programming in RISC-V. I think it is a promising architecture, and I wanted to create something visual that shows how much can be accomplished even at such a low level.
