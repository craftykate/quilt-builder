class BuildQuilt

	def initialize

		############ EDIT THESE ############
		# How many rows long should the quilt be?
		@needed_rows = 18
		# How many columns wide should the quilt be?
		@needed_columns = 18
		# How many colors are there?
		colors = 9
		# How big should each unique square be?
		@square_size = 9
		############ STOP EDITING ############

		@all_colors = []
		# Turns colors variable into an array of numbers
		build_colors(colors)
		@all_options = @all_colors.permutation(@square_size).to_a
		# Starts building quilt
		build_quilt
	end

	def build_colors(colors)
		0.upto(colors - 1) do |num|
			@all_colors << num
		end
	end

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
		loop do 
			break if @quilt_board.length == @needed_rows
			row, @quilt_board = get_row(@quilt_board, @square_size)[0..1]
			if row == false
				@quilt_board.pop
				@quilt_board.pop
				tries += 1
				if tries % 3 == 0
					if @quilt_board.length < @square_size
						@quilt_board = []
					else
						how_many_full_blocks = @quilt_board.length / @square_size
						(@quilt_board.length - (how_many_full_blocks * @square_size)).times { @quilt_board.pop }
					end
				end
			else
				@quilt_board << row
				print "#{@quilt_board.length} "
			end
		end
		if @needed_columns > @square_size
			build_right
		end
		show_quilt
		build_index
	end

	def build_right
 		puts "\n\nBuilding right side..."
 		print "Quilt row: "
		@quilt_board_right = []
		tries = 0
		check_options = nil
		loop do 
			block_length = @quilt_board_right.length
			break if block_length == @needed_rows
			potential_row, @quilt_board_right, opt_length = get_row(@quilt_board_right, (@needed_columns - @square_size))
			if potential_row == false
				@quilt_board_right.pop
				@quilt_board_right.pop
				tries += 1
				if tries % 3 == 0
					if block_length < @square_size
						@quilt_board_right = []
					else
						how_many_full_blocks = @quilt_board_right.length / @square_size
						(@quilt_board_right.length - (how_many_full_blocks * @square_size)).times { @quilt_board_right.pop }
					end
				end
			else
				if block_length == 0 && potential_row[0] != @quilt_board[0][-1] && potential_row[0] != @quilt_board[1][-1]
					@quilt_board_right << potential_row
					print "#{@quilt_board_right.length} "
				elsif block_length.between?(1, (@needed_rows - 2)) && potential_row[0] != @quilt_board[block_length - 1][-1] && potential_row[0] != @quilt_board[block_length][-1] && potential_row[0] != @quilt_board[block_length + 1][-1]
					@quilt_board_right << potential_row
					print "#{@quilt_board_right.length} "
				elsif block_length == (@needed_rows - 1) && potential_row[0] != @quilt_board[-2][-1] && potential_row[0] != @quilt_board[-1][-1]
					@quilt_board_right << potential_row
					print "#{@quilt_board_right.length} "
				else
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

	def show_quilt
		stats = Hash.new(0)
		puts "\n\nFinal quilt:\n"
		@quilt_board.each_with_index do |row, i|
			print "#{row} "
			print "#{@quilt_board_right[i]}" if @quilt_board_right != nil
			puts if (i + 1) % @square_size == 0
			puts
			row.each do |square|
				stats[square] += 1
			end
		end
		display_stats(stats)
	end

	def display_stats(stats)
		stats_arr = stats.sort_by { |color, amount| amount }
		stats_arr = stats_arr.sort { |x, y| [y[1], x[0]] <=> [x[1], y[0]] }
		puts
		stats_arr.each do |row|
			puts "Color #{row[0]}: #{row[1]}"
		end
	end

	def build_index
		
	end

	def get_row(quilt_board, board_rows)
		columns, quilt_board = get_list_of_column_numbers(quilt_board)
		get_current_options(columns, quilt_board, board_rows)
		return false, quilt_board, @current_options.length if @current_options.empty? 
		return @current_options.sample[0..(board_rows-1)], quilt_board, @current_options.length
	end

	def get_list_of_column_numbers(quilt_board)
		columns = Hash.new
		num_rows = quilt_board.length
		if num_rows.between?(1, (@square_size - 1))
			quilt_board.each do |board_row|
				board_row.each_with_index do |num, num_index|
					columns[num_index] ||= []
					columns[num_index] << num
				end
			end
		elsif num_rows != 0 && num_rows % @square_size == 0
			quilt_board[-1].each_with_index do |num, num_index|
				columns[num_index] ||= []
				columns[num_index] << num
			end
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

	def get_current_options(columns, quilt_board, board_rows)
		@current_options = []
		@all_options.each { |opt| @current_options << opt }
		if quilt_board.length > 0
			@current_options = get_rid_of_duplicate_columns(columns)
			@current_options = get_rid_of_upper_left(quilt_board, board_rows)
			@current_options = get_rid_of_upper_right(quilt_board, board_rows)
		end
	end

	def get_rid_of_duplicate_columns(columns)
		columns.length.times do |x|
			@current_options = @current_options.select do |option|
				columns[x].include?(option[x]) == false
			end
		end
		@current_options
	end

	def get_rid_of_upper_left(quilt_board, board_rows)
		1.upto(board_rows - 1) do |x|
			@current_options = @current_options.select do |option|
				quilt_board[-1][x - 1] != option[x]
			end
		end
		@current_options
	end

	def get_rid_of_upper_right(quilt_board, board_rows)
		0.upto(board_rows - 2) do |x|
			@current_options = @current_options.select do |option|
				quilt_board[-1][x + 1] != option[x]
			end
		end
		@current_options
	end
end

BuildQuilt::new