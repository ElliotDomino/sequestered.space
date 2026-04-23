.data
# Configuration settings
gridWidth:	.word 20
gridHeight:	.word 15
refreshRate:	.word 100	# milliseconds
gridSeed:	.string "Hello"
gridSeedEnd:

.text
.globl main

#====================================================
# main
# Controls main flow of the program. Initializes the
# board, sets its initial values, 
#====================================================
main:
	# Start by initializing the grid in memory
	call allocateGrid
	mv s0, a0	# s0 will hold address to grid
	
	# Next, set the initial state of the grid based on the gridSeed
	
	
	# exit the program
	li a7, 10
    	ecall

#====================================================
# allocateGrid
# Allocates memory for grid:
# The grid is bit-packed, meaning that each memory
# address can hold up to 8 "cells" (being 1 or 0 for
# on or off)
#
# Inputs: none
# 
# Outputs: a0 = pointer to allocated grid start
#====================================================
allocateGrid:
	# Load width and height vars
	lw t0, gridWidth
	lw t1, gridHeight
	
	mul t2, t0, t1	# t2 holds the required number of bits for grid storage
	addi t2, t2, 7	# round up by adding 7 and dividing by 8
	srli t2, t2, 3	# divide by 8 = dividing by 2^3 = shift right by 3 bits
	
	mv a0, t2	# set a0 to number of bytes needed for grid
	li a7, 9	# call sbrk for dynamic memory allocation
	ecall
	
	ret		# result of sbrk is pointer to memory address of grid (already in a0)
	

#====================================================
# getCellAddress
# Given the input row and column of a cell, the address
# of that cell will be returned along with the cell's
# offset (within the address)
# 
# Inputs: a0 = row
#	  a1 = col
#	  a2 = grid start address
#
# Outputs: a0 = address of byte containing cell
# 	   a1 = bit offset to cell
#====================================================
getCellAddress:
	lw t0, gridWidth
	
	mul t1, a0, t0	# t1 = row * width
	add t1, t1, a1	# t1 = (row * width) + col
	
	srli t2, t1, 3	# t2 = byte index = t1 / 8
	andi t3, t1, 7	# t3 = bit offset = t1 % 8
	
	add a0, a2, t2	# a0 = byte address
	mv a1, t3	# a1 = bit offset
	
	ret
	
#====================================================
# seedGrid
# Copies gridSeed into the bit-packed grid.
# - If the seed is shorter than the grid, the rest
#   of the grid is filled with 0s.
# - If the seed is longer than the grid, it is cut off.
# - If the grid size is not a multiple of 8 bits,
#   the unused bits in the final byte are cleared.
#
# Input: a0 = grid base address
#
# Output: none
#====================================================
seedGrid:
	mv t6, a0	# save the address of the grid start in t6
	
	# totalBits = width * height
	lw t0, gridWidth
	lw t1, gridHeight
	mul t2, t0, t1	# t2 = totalBits
	
	# totalbytes = (totalBits + 7) / 8
	addi t3, t2, 7
	srli, t3, t3, 3	# t3 = totalBytes
	
	# Zero the whole grid before setting seed
	mv t4, t6	# current byte pointer is t4
	mv t5, t3	# byte counter is t5	
zeroLoop:
	beqz t5, zeroDone	# branch to zeroDone when t5 is equal to 0
	sb zero, 0(t4)
	addi t4, t4, 1		# increment t4
	addi t5, t5, -1		# decrement t5
	j zeroLoop
zeroDone:
	# begin the copy of gridSeed into grid
	
	la t0, gridSeed		# t0 = seed start
	la t1, gridSeedEnd	# t1 = seed end
	sub t1, t1, t0		# t1 = total bytes (including null terminator)
	addi t1, t1, -1		# t1 = total bytes (exclusing null terminator)
	
	# if seed size <= 0, then there is nothing to copy
	bge zero, t1, maskFinalByte
	
	# bytesToCopy = min(gridBytes, seedSize)
	blt t3, t1, useGridBytes
	mv t5, t1
	j copyStart
useGridBytes:
	mv t5, t3

copyStart:
	# by here, t5 is either set to gridBytes (t3) or seedSize (t1)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
