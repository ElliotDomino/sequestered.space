---
title: "CCD Inverse Kinematics in Javascript"
slug: "inverse-kinematics"
index: "002"
status: "published"
date: "2026-04-22"
category: "ALGO"
thought: "Complex motion can emerge from a simple loop: look at the target, adjust one joint, and repeat until the whole chain reaches where it needs to go."
---

Cyclic Coordinate Descent Inverse Kinematics (CCD) is a method for finding the best rotation for each joint in a chain, starting near the end of the arm and working backward. With each pass, the end effector moves closer to its target.

> **Note:** The sliders may not work properly on mobile. This was a small morning exercise, so the demo is best viewed on desktop.

## Links
* **Repo:** [Inverse Kinematics source on GitHub](https://github.com/ElliotDomino/inverse-kinematics-js.git)
* **Demo:** [Live CCD Inverse Kinematics Demo](./resources/index.html)

## The Algorithm
The CCD inverse kinematics algorithm relies on a simple iterative process to position a chain of joints so that an end effector reaches a target:

1. **End-effector targeting**: Measure how the final point in the chain needs to move to approach the target.
2. **Joint rotation**: Starting from the joint nearest the end effector and working backward, rotate each joint to better align the end effector with the target.
3. **Iteration**: Repeat these adjustments until the end effector is sufficiently close to the target or the iteration limit is reached.

Together, these steps create **smooth, natural-looking motion** that allows articulated structures such as robotic arms and character limbs to reach toward a goal.

![CCD Inverse Kinematics Demonstration](./resources/inverse-kinematics.png)

For a broader explanation of the problem, see the [Wikipedia article on inverse kinematics](https://en.wikipedia.org/wiki/Inverse_kinematics).

## Context
I wanted to create another small JavaScript demo after finishing my exams this semester. I had implemented inverse kinematics before using a visual scripting language in a game, and thought it would be fun to recreate the idea as an interactive project for my site.
