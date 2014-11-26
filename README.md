# Quilt Program

## Overview

This is a program I built while putting together a quilt of crochet granny squares. I input a few variables into the program (how many rows and columns I want, how many colors I have etc) and the program will put together the squares so that no color is touching another square of the same color either on the sides or the corners. Say I'm using 9 colors and want blocks of size 8x8 where no color is repeated in the same column or row, and doesn't touch another block of the same color. It will then put together as many 8x8 blocks (or fraction thereof) as needed until the quilt is the right size. 

## Why I built this program

It's hard to come up with unique blocks! By the end of each block it's often impossible to come up with an 8th row. It was taking me way too much time to just come up with a small square of unique blocks, let alone a large quilt just the way I wanted it. So I decided to let my computer do the heavy lifting for me. 

## Instructions

1. Download program to folder of your choice
2. Open `build_quilt.rb` and change the following variables:
- **@needed_rows**: Input how many rows _long_ the quilt should be
- **@needed_columns**: Input how many columns _wide_ the quilt should be
- **colors**: Input how many different colors you are using
- **@square_size**: Input how big each unique square should be. _Note: this can NOT be bigger than the amount of colors you have!_
3. Navigate to `quilt_program` folder in terminal and run `ruby build_quilt.rb`
- Program will build the quilt with the specified variables and spit out in the terminal window the final combination, along with the amount of squares used for each color. This will help you decide which color to assign to each number. Say color 3 has the most squares and color 6 has the fewest. Maybe you want more orange and less blue - simply assign orange to color 3 and blue to color 6!

## Examples 
