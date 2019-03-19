require 'yaml'
require 'csv'

class Game

    def initialize
        puts "Current directory: #{Dir.pwd}"
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

        images = File.read("hangman.yaml")
        @hangman = images.split(',')

    end


    def game_intro
        puts "Welcome to Hangman!"
        puts "Would you like to play a new game, or load a previous one? (n/l)"
        play = gets.chomp.downcase
        until play == 'n' or play == 'l'
            puts "That is not an option, enter either (n)ew or (l)oad."
            play = gets.chomp.downcase
        end
        if play == 'l'
            Dir.chdir "saves"
            saves = Dir.glob('*')
            puts "Current saves: #{saves}"
            puts "Which game would you like to load?"
            @selection = gets.chomp.downcase
            game = File.exists? "#{@selection}"
            if game == true
                load_game
            else
                puts "There is no game with that name on file."
                puts "Either enter a new one, or exit to exit."
            end
        else
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
        end
        puts @players_array.join(' ')
    end

    def play_a_game
        game_intro
        while @turn_counter < 8
            puts "Turn: #{@turn_counter}"
            puts @hangman[@turn_counter - 1]
            puts
            retrieve_guess
            update_display
            check_for_win
        end
        puts "Oh no! You lose.."
        puts "The word was: #{@secret_word}"
    end

    def retrieve_guess
        puts "Pick a letter! Or enter 'save' to save, or 'exit' to exit."
        @guess = gets.chomp.downcase
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
        puts
        puts
        puts "Mistakes left: #{8 - @turn_counter}"
        puts @players_array.join(' ')
        puts "Letters guessed so far: #{@guessed_letters.join(', ')}"

    end

    def guess_filter(guess)

        until @guess.length == 1 and @guess =~ /[a-z]/
            if @guess == 'save'
                save_game
            elsif @guess == 'exit'
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
        exists = Dir.exists? "saves"
        if exists == false
            Dir.mkdir "saves"
        end
        Dir.chdir "saves"
        puts "Enter a name for the save file."
        save_id = gets.chomp.downcase.to_s
        until save_id != 'exit'
            puts "You cannot save a file with that name."
            save_id = gets.chomp.downcase.to_s
        end
        game_state = YAML::dump({

            :secret_word => @secret_word,
            :players_array => @players_array,
            :turn_counter => @turn_counter,
            :guessed_letters => @guessed_letters
        })
        if File.exists? "#{save_id}"
            puts "A file already exists with that name, are you sure? (y/n)"
            confirm = gets.chomp.downcase
            until confirm == 'y' or confirm == 'n'
                puts "That is not an option, enter (y)es or (n)o."
                confirm = gets.chomp.downcase
            end
            if confirm == 'y'
                puts "File overwritten!"
                save = File.new("#{save_id}", "w+")
                save.puts game_state
                save.close
            end
        else
            puts "New file saved!"
            save = File.new("#{save_id}", "w+")
            save.puts game_state
            save.close
        end
        puts "Now that we're done with that, enter a new letter, or 'exit' to exit the game."
        Dir.chdir ".."
    end

    def load_game
        puts Dir.getwd
        game = YAML.load(File.open("#{@selection}", 'r'))
        @secret_word = game[:secret_word]
        @secret_array = @secret_word.split('')
        @players_array = game[:players_array]
        @guessed_letters = game[:guessed_letters]
        @turn_counter = game[:turn_counter]

    end
end

new_game = Game.new
new_game.play_a_game
