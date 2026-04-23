.data
# Configuration settings
gridWidth:	.word 20
gridHeight:	.word 15
refreshRate:	.word 100     # milliseconds
gridSeed:	.word 12345

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
# No inputs.
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
# Writes gridSeed into the grid, then fills any
# remaining cells with 0.
#
# If the grid has fewer than 32 cells, only the
# lowest needed bits of gridSeed are used.
#
# Input:
#   a0 = grid base address
#
# Output:
#   none
#====================================================