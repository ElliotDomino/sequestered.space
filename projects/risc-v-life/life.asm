.data
# Display settings
.align 2
frameBuffer:	.space 4096	# aligned on words
# Configuration settings
gridWidth:	.word 8
gridHeight:	.word 8
refreshRate:	.word 100	# milliseconds
gridSeed:
    #.byte 0x48, 0x65, 0x6C, 0x6C, 0x6F				# H e l l o
    .byte 0x00, 0x42, 0x42, 0x00, 0x00, 0x42, 0x3C, 0x00	# Smiley Face
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
	call seedGrid	# address of grid already in a0
	
	# render grid to bitmap framebuffer
	mv a0, s0
	la a1, frameBuffer
	call renderGrid
	
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
# getPixelAddress
# Given the input row and column of a pixel, the address
# of that framebuffer pixel will be returned
#
# Inputs:  a0 = row
#          a1 = col
#          a2 = framebuffer base address
#
# Output:  a0 = address of pixel
#====================================================
getPixelAddress:
	lw t0, gridWidth	# display width matches grid width
	mul t1, a0, t0
	add t1, t1, a1
	slli t1, t1, 2		# multiply by 4 bytes per pixel
	add a0, a2, t1
	ret
	
#====================================================
# getCell
# Returns cell value at given row and col
#
# Inputs:  a0 = row
#          a1 = col
#          a2 = grid base address
#
# Output:  a0 = cell value (0 or 1)
#====================================================
getCell:
	# since getCell calls getCellAddress, we need to store the stack pointer
	addi sp, sp, -4
	sw ra, 0(sp)

	call getCellAddress	# returns a0 = byte address, a1 = bit offset

	# load byte into t0
	lb t0, 0(a0)
	
	li t1, 7
	sub t1, t1, a1		# flip bit order within byte (so that it comes up left to right on the display)
	li t2, 1
	sll t2, t2, t1
	and t0, t0, t2
	snez a0, t0

	# load the stack pointer again
	lw ra, 0(sp)
	addi sp, sp, 4
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
	srli t3, t3, 3	# t3 = totalBytes
	
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
	sub t1, t1, t0		# t1 = total bytes
	
	# if seed size <= 0, then there is nothing to copy
	bge zero, t1, copyDone
	
	# bytesToCopy = min(gridBytes, seedSize)
	blt t3, t1, useGridBytes
	mv t5, t1
	j copyStart
useGridBytes:
	mv t5, t3

copyStart:
	# by here, t5 is either set to gridBytes (t3) or seedSize (t1)
	la t0, gridSeed		# t0 = seed start pointer
	mv t4, t6		# t4 = grid start pointer
copyLoop:
	beqz t5, copyDone	# branch to copyDone if t5 = zero
	
	lb t1, 0(t0)		# load seed byte
	sb t1, 0(t4)		# store byte from seed into grid
	
	addi t0, t0, 1		# increment t0
	addi t4, t4, 1		# increment t4
	addi t5, t5, -1		# decrement t5
	
	j copyLoop

copyDone:
	# once the copy is complete, then we clear the unused bits if needed
	
	# remainderBits = totalBits % 8
	andi t0, t2, 7		# t0 = remainderBits
	beqz t0, seedDone	# if no remainder, then seeding is done
	
	li t1, 1
	sll t1, t1, t0		# t1 = 1 << remainderBits
	addi t1, t1, -1		# t1 is a mask for valid bits
	
	addi t4, t3, -1		# t4 is the last byte index
	add t4, t6, t4		# t4 is the address of the final byte in the grid
	
	# clear unused bits using the mask
	lb t5, 0(t4)
	and t5, t5, t1
	sb t5, 0(t4)

seedDone:
	ret
	
#====================================================
# renderGrid
# Draws the grid into the bitmap framebuffer
#
# Inputs:  a0 = grid base address
#          a1 = framebuffer base address
#
# Output:  none
#====================================================
renderGrid:
	addi sp, sp, -24
	sw ra, 20(sp)
	sw s0, 16(sp)
	sw s1, 12(sp)
	sw s2, 8(sp)
	sw s3, 4(sp)
	sw s4, 0(sp)
	
	mv s0, a0	# s0 = grid pointer
	mv s1, a1	# s1 = framebuffer base
	
	li s2, 0	# s2 = row
	
renderRowLoop:
	lw t0, gridHeight
	bge s2, t0, renderDone	# if row >= gridHeight then go to renderDone
	
	li s3, 0		# s3 = col

renderColLoop:
	lw t0, gridWidth
	bge s3, t0, nextRow	# if col >= gridWidth then go to nextRow
	
	# get cell value
	mv a0, s2
	mv a1, s3
	mv a2, s0
	call getCell		# a0 = 0 or 1 depending on cell 
    
    	beqz a0, drawBlack	# if cell is 0, then go to drawBlack
    	li s4, 0x00FFFFFF	# load white into s4
    	j drawPixel
drawBlack:
    	li s4, 0x00282828 	# load (off-) black into s4
drawPixel:
    	mv a0, s2
    	mv a1, s3
    	mv a2, s1
    	call getPixelAddress
    	
    	sw s4, 0(a0)		# store color in pixel's address

	addi s3, s3, 1		# increment col
	j renderColLoop
	
nextRow:
	addi s2, s2, 1		# increment row
	j renderRowLoop
	
renderDone:
	lw s4, 0(sp)
	lw s3, 4(sp)
	lw s2, 8(sp)
	lw s1, 12(sp)
	lw s0, 16(sp)
	lw ra, 20(sp)
	addi sp, sp, 24
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
