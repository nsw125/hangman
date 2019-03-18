require 'yaml'

class Game

    def initialize
        word_bank = Array.new
        File.open('dictionary.txt','r').each do |line|
            line = line.chomp.downcase
            if line.length > 4 and line.length < 13
                word_bank.push(line)
            end
        end
        @secret_word = word_bank[rand(1..word_bank.length)].chomp.downcase
        @secret_array = @secret_word.split('')

        @players_array = []
        @secret_array.length.times { @players_array.push('-') }

        @guessed_letters = Array.new
        @turn_counter = 1

        @already_saved = false

        puts "Welcome to Hangman!"
        puts
        puts "Guess the word, letter by letter!"
        puts "Enter one at a time, and if you get it right,"
        puts "It will show up at it's correct place in the word!"
        puts
        puts "However, if the letter you guess isn't in the word..."
        puts
        puts "Thats one strike!"
        puts
        puts "You get seven strikes to guess the word! Good Luck and have fun!"
        puts
        puts
        puts 
        puts @players_array.join(' ')

    end

    def play_a_game
        while @turn_counter < 8
            puts "Turn: #{@turn_counter}"
            retrieve_guess
            update_display
            check_for_win
        end
        puts "Oh no! You lose.."
        puts "The word was: #{@secret_word}"
    end

    def retrieve_guess
        puts "Pick a letter!" #Or enter 'save' to save this game to return to later!
        @guess = gets.chomp.downcase
        #if @guess == 'save'
        #    save_game
        #end
        guess_filter(@guess)
        already_guessed = @guessed_letters.any? { |letter| @guess == letter }
        if already_guessed == true
            puts "You have already guessed that, pick another letter!"
            puts "You can see which letters you have already guessed!"
        else
            @guessed_letters.push(@guess)
            if @secret_array.none? { |letter| letter == @guess}
                puts "Nope, that isn't found in this word."
                @turn_counter += 1
            else
                puts "Yep! That letter is found in this word!"
            end
        end
        puts "Letters guessed so far: #{@guessed_letters.join(', ')}"
        puts
        puts

    end

    def check_for_win
        if @players_array == @secret_array
            puts 'You win! Congratulations!'
            puts "The word was: #{@secret_word}"
            exit
        end
    end

    def update_display
        
        @secret_array.each_with_index do |letter,index|
            if letter == @guessed_letters.last
                @players_array[index] = letter
            end
        end
        puts "Mistakes left: #{8 - @turn_counter}"
        puts @players_array.join(' ')
    end

    def guess_filter(guess)

        until @guess.length == 1 and @guess =~ /[a-z]/
            if @guess == 'exit'
                exit
            elsif @guess.length == 0
                puts "You didn't enter anything! If you wish to exit, enter exit."
            elsif @guess !~ /^[a-z]/
                puts "Woahhh, that's not a letter, bud! Try again."
            else
                puts "Take it easy! You can only enter a single letter at a time, try again."
            end
            @guess = gets.chomp.downcase
        end
    end

    def save_game
        save_id = 0
        game_state = YAML::dump(self)
        if @already_saved == true
            File.open("save_file#{save_id}", "w").puts game_state
            puts "Old game overwritten! You're good to go!"
        else
            while File.exists? "save_file#{save_id}"
                save_id += 1
            end
            File.new "save_file#{save_id}"
            puts "New file saved!"
            @already_saved = true
        end
    end
end

game = Game.new
game.play_a_game
