require 'erb'

class BuildQuilt

	def initialize

		############ EDIT THESE ############
		# How many rows long should the quilt be?
		@needed_rows = 6
		# How many columns wide should the quilt be?
		@needed_columns = 18
		# How many colors are there?
		@colors = 9
		# How big should each unique square be?
		@square_size = 9
		############ STOP EDITING ############

		@all_colors = []
		# Turns colors variable into an array of numbers
		build_colors
		@all_options = @all_colors.permutation(@square_size).to_a
		# Starts building quilt
		build_quilt
	end

	def build_colors
		0.upto(@colors - 1) do |num|
			@all_colors << num
		end
	end

	# Builds the left side of the quilt
	def build_quilt
		# Output variables used
		puts "\nBuilding quilt..."
		puts "\n-----------------------------------------"
		puts "Dimensions: #{@needed_columns} columns by #{@needed_rows} rows"
		puts "Using squares of #{@square_size} by #{@square_size} with #{@all_colors.length} colors"
		puts "-----------------------------------------"
		puts "\nBuilding left side..."
		print "Quilt row: "
		@quilt_board = []
		tries = 0
		# Continue loop until all rows have been built
		loop do 
			# Stop loop when all rows are made
			break if @quilt_board.length == @needed_rows
			# Get the next row
			row, @quilt_board = get_row(@quilt_board, @square_size)[0..1]
			# If there are no options left...
			if row == false
				# Delete the last two rows and try again. Sometimes there will be no options depending on which rows it picked, so this will usually help
				@quilt_board.pop
				@quilt_board.pop
				tries += 1
				# If it has tried this three times, just start the current square over. This will fix it if it really gets stuck.
				if tries % 3 == 0
					if @quilt_board.length < @square_size
						@quilt_board = []
					else
						# Only delete the current square, not the whole thing
						how_many_full_blocks = @quilt_board.length / @square_size
						(@quilt_board.length - (how_many_full_blocks * @square_size)).times { @quilt_board.pop }
					end
				end
			else
				# Row is valid, so add it to quilt
				@quilt_board << row
				# Print which row it just built
				print "#{@quilt_board.length} "
			end
		end
		# If the quilt is wider than one block, build the right side
		if @needed_columns > @square_size
			build_right
		end
		# If the quilt is wider than two blocks, build the far right side
		if @needed_columns > @square_size * 2
			build_far_right
		end
		# Show the quilt
		show_quilt
		# Build html page for the quilt
		build_index
	end

	# Build the right side
	def build_right
 		puts "\n\nBuilding right side..."
 		print "Quilt row: "
		@quilt_board_right = []
		tries = 0
		check_options = nil
		# Continue loop until all rows have been made
		loop do 
			block_length = @quilt_board_right.length
			# Break loop when done
			break if block_length == @needed_rows
			# Calculate how wide block should be
			if @needed_columns - @square_size <= @square_size
				width = @needed_columns - @square_size
			else
				width = @square_size
			end
			# Get next potential row
			potential_row, @quilt_board_right, opt_length = get_row(@quilt_board_right, width)
			# If there are no options left...
			if potential_row == false
				# Delete the last two rows and start again
				@quilt_board_right.pop
				@quilt_board_right.pop
				tries += 1
				# If this has been tried a few times start the square over
				if tries % 3 == 0
					if block_length < @square_size
						@quilt_board_right = []
					else
						# Only delete the current square, not the whole thing
						how_many_full_blocks = @quilt_board_right.length / @square_size
						(@quilt_board_right.length - (how_many_full_blocks * @square_size)).times { @quilt_board_right.pop }
					end
				end
			else
				# The current row satisfies the current block, not the left side of the quilt, so check that here. Make sure left edge of the row doesn't match the right edge of the left side.
				# This is for the top row
				if block_length == 0 && potential_row[0] != @quilt_board[0][-1] && potential_row[0] != @quilt_board[1][-1]
					@quilt_board_right << potential_row
					print "#{@quilt_board_right.length} "
				# This is for the middle rows
				elsif block_length.between?(1, (@needed_rows - 2)) && potential_row[0] != @quilt_board[block_length - 1][-1] && potential_row[0] != @quilt_board[block_length][-1] && potential_row[0] != @quilt_board[block_length + 1][-1]
					@quilt_board_right << potential_row
					print "#{@quilt_board_right.length} "
				# This is for the last row
				elsif block_length == (@needed_rows - 1) && potential_row[0] != @quilt_board[-2][-1] && potential_row[0] != @quilt_board[-1][-1]
					@quilt_board_right << potential_row
					print "#{@quilt_board_right.length} "
				else
					# Sometimes the right side block gets stuck and comes up with the same options (say, 3) over and over. The block itself still has options, but none that satisfy the left side of the quilt. If it does this 10 times delete the last two rows of the block.
					if check_options == opt_length
						tries += 1
						if tries % 10 == 0
							@quilt_board_right.pop
							@quilt_board_right.pop
						end
					end
					check_options = opt_length
				end
			end
		end
	end

	# Build the right side
	def build_far_right
 		puts "\n\nBuilding far right side..."
 		print "Quilt row: "
		@quilt_board_far_right = []
		tries = 0
		check_options = nil
		# Continue loop until all rows have been made
		loop do 
			block_length = @quilt_board_far_right.length
			# Break loop when done
			break if block_length == @needed_rows
			# Get next potential row
			potential_row, @quilt_board_far_right, opt_length = get_row(@quilt_board_far_right, (@needed_columns - (@square_size * 2)))
			# If there are no options left...
			if potential_row == false
				# Delete the last two rows and start again
				@quilt_board_far_right.pop
				@quilt_board_far_right.pop
				tries += 1
				# If this has been tried a few times start the square over
				if tries % 3 == 0
					if block_length < @square_size
						@quilt_board_far_right = []
					else
						# Only delete the current square, not the whole thing
						how_many_full_blocks = @quilt_board_far_right.length / @square_size
						(@quilt_board_far_right.length - (how_many_full_blocks * @square_size)).times { @quilt_board_far_right.pop }
					end
				end
			else
				# The current row satisfies the current block, not the left side of the quilt, so check that here. Make sure left edge of the row doesn't match the right edge of the left side.
				# This is for the top row
				if block_length == 0 && potential_row[0] != @quilt_board_right[0][-1] && potential_row[0] != @quilt_board_right[1][-1]
					@quilt_board_far_right << potential_row
					print "#{@quilt_board_far_right.length} "
				# This is for the middle rows
				elsif block_length.between?(1, (@needed_rows - 2)) && potential_row[0] != @quilt_board_right[block_length - 1][-1] && potential_row[0] != @quilt_board_right[block_length][-1] && potential_row[0] != @quilt_board_right[block_length + 1][-1]
					@quilt_board_far_right << potential_row
					print "#{@quilt_board_far_right.length} "
				# This is for the last row
				elsif block_length == (@needed_rows - 1) && potential_row[0] != @quilt_board_right[-2][-1] && potential_row[0] != @quilt_board_right[-1][-1]
					@quilt_board_far_right << potential_row
					print "#{@quilt_board_far_right.length} "
				else
					# Sometimes the right side block gets stuck and comes up with the same options (say, 3) over and over. The block itself still has options, but none that satisfy the left side of the quilt. If it does this 10 times delete the last two rows of the block.
					if check_options == opt_length
						tries += 1
						if tries % 10 == 0
							@quilt_board_far_right.pop
							@quilt_board_far_right.pop
						end
					end
					check_options = opt_length
				end
			end
		end
	end

	# Display the final quilt, while storing the stats as it goes through
	def show_quilt
		stats = Hash.new(0)
		puts "\n\nFinal quilt:\n"
		# Go through each row and display it
		@quilt_board.each_with_index do |row, i|
			print "#{row} "
			# Display the right side of the quilt if it exists
			print "#{@quilt_board_right[i]} " if @quilt_board_right != nil
			# Display the right side of the quilt if it exists
			print "#{@quilt_board_far_right[i]}" if @quilt_board_far_right != nil
			# If it has reached the end of a unique block put an empty line
			puts if (i + 1) % @square_size == 0
			puts
			# Add 1 to the count of that color to the stats hash
			row.each do |square|
				stats[square] += 1
			end
			if @quilt_board_right != nil
				@quilt_board_right[i].each do |square|
					stats[square] += 1
				end
			end
			if @quilt_board_far_right != nil
				@quilt_board_far_right[i].each do |square|
					stats[square] += 1
				end
			end
		end
		# Show the stats
		display_stats(stats)
	end

	# Display the stats for each color
	def display_stats(stats)
		# Put the stats info into an array to sort
		@stats_arr = stats
		# Sort the array first by the amount of color used descending (first index) and then by the color name ascending (zeroth index)
		@stats_arr = @stats_arr.sort { |x, y| [y[1], x[0]] <=> [x[1], y[0]] }
		puts
		@stats_arr.each do |row|
			puts "Color #{row[0]}: #{row[1]}"
		end
	end

	# Get the next potential row
	def get_row(quilt_board, board_rows)
		# Get a list of which colors are used in each row
		columns, quilt_board = get_list_of_column_numbers(quilt_board)
		# Narrow down the options to only valid rows
		get_current_options(columns, quilt_board, board_rows)
		# Return false if there are no options left
		return false, quilt_board, @current_options.length if @current_options.empty? 
		# Return the potential row if it exists, trimming the row if a fraction of a square is needed
		return @current_options.sample[0..(board_rows-1)], quilt_board, @current_options.length
	end

	# Get the list of which colors are in which columns
	def get_list_of_column_numbers(quilt_board)
		columns = Hash.new
		num_rows = quilt_board.length
		# If the next row is in the middle or end of the first block, get all the columns of the block
		if num_rows.between?(1, (@square_size - 1))
			quilt_board.each do |board_row|
				board_row.each_with_index do |num, num_index|
					columns[num_index] ||= []
					columns[num_index] << num
				end
			end
		# If the next row is at the top of the next block, just get the row above it
		elsif num_rows != 0 && num_rows % @square_size == 0
			quilt_board[-1].each_with_index do |num, num_index|
				columns[num_index] ||= []
				columns[num_index] << num
			end
		# If the next row is in the middle or end of a block that ISN'T the first block, get the columns from just that block
		elsif num_rows != 0
			rows_to_check = (num_rows % @square_size)
			1.upto(rows_to_check) do |x|
				quilt_board[-x].each_with_index do |num, num_index|
					columns[num_index] ||= []
					columns[num_index] << num
				end
			end
		end
		return columns, quilt_board
	end

	# Narrow down options to only valid rows
	def get_current_options(columns, quilt_board, board_rows)
		@current_options = []
		# At the start of every row put ALL options into variable
		@all_options.each { |opt| @current_options << opt }
		if quilt_board.length > 0
			# Get ride of any row that repeats a color in the same column
			@current_options = get_rid_of_duplicate_columns(columns)
			# Get rid of any row that has a color touching a square of the same color in the upper left
			@current_options = get_rid_of_upper_left(quilt_board, board_rows)
			# Same thing but for upper right
			@current_options = get_rid_of_upper_right(quilt_board, board_rows)
		end
	end

	# Gets rid of any options that repeats a color in the same column
	def get_rid_of_duplicate_columns(columns)
		columns.length.times do |x|
			# Only select rows that don't repeat colors in a column
			@current_options = @current_options.select do |option|
				columns[x].include?(option[x]) == false
			end
		end
		@current_options
	end

	# Get rid of any options that have colors touching at the upper left
	def get_rid_of_upper_left(quilt_board, board_rows)
		1.upto(board_rows - 1) do |x|
			# Select only rows that don't touch the same color one row above
			@current_options = @current_options.select do |option|
				quilt_board[-1][x - 1] != option[x]
			end
		end
		@current_options
	end

	# Get rid of any options that have colors touching at the upper right
	def get_rid_of_upper_right(quilt_board, board_rows)
		0.upto(board_rows - 2) do |x|
			# Select only rows that don't touch the same color one above
			@current_options = @current_options.select do |option|
				quilt_board[-1][x + 1] != option[x]
			end
		end
		@current_options
	end

	# Build the html page for the quilt
	def build_index

		# Names the file based on date and time for uniqueness and ability to find which one you want later
		t = Time.now
		@file_time = t.strftime("%Y.%b.%d_%H.%M.%S")
		@filename = "quilt_pages/#{@needed_rows}x#{@needed_columns}_#{@file_time}.html"

		# Store the quilt page template in a variable
		quilt_template = File.read "templates/quilt_template.erb"
		# Start a new ERB
		erb_template = ERB.new quilt_template
		# Pull it all together and put info into one variable
		quilt_page = erb_template.result(binding)

		# Makes the directory for the quilt pages if there isn't one
		Dir.mkdir("quilt_pages") unless Dir.exists? "quilt_pages"

		# Opens the file and saves (actually writes) the quilt info
		File.open(@filename, 'w') do |file|
			file.puts quilt_page
		end

		system("open #{@filename}")
	end
end

BuildQuilt::new