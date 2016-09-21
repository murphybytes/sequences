#!/usr/bin/env ruby -w

require 'set'
require 'open-uri'

unique_sequences = {}
duplicate_sequences = Set.new


def get_sequences_from_word(word)
  result = []
  length = word.length
  start = 0

  while (length - start) > 3 do
    result << word.slice(start, 4)
    start += 1
  end
  result
end

def prune_reoccuring_sequence(duplicate_sequences, unique_sequences, seq)
  unique_sequences.delete(seq)
  duplicate_sequences.add(seq)
end

def process_word(duplicate_sequences, unique_sequences, word)
  word.chomp!
  sequences = get_sequences_from_word(word)
  sequences.each do |seq|
    next if duplicate_sequences.include?(seq)
    if unique_sequences.key?(seq)
      prune_reoccuring_sequence(duplicate_sequences, unique_sequences, seq)
    else
      unique_sequences[seq] = word
    end
  end
end

if ARGV.length == 0
  open("https://dl.dropboxusercontent.com/u/14065136/dictionary.txt") do |f|

    f.each_line do |word|
      process_word(duplicate_sequences, unique_sequences, word)
    end
  end

  puts %q('sequences'        'words')
  puts

  unique_sequences.keys.sort.each do |seq|
    puts "#{seq}               #{unique_sequences[seq]}"
  end

  puts
end


if ARGV[0] == 'test'

  require 'test/unit'
  require 'test/unit/ui/console/testrunner'

  class SeqTest < Test::Unit::TestCase
    def setup
      @words = %w(arrows carrots give me)
      @candidates = {}
      @pruned = Set.new
    end

    def test_seq
      expected = %w(arro rrow)
      actual = get_sequences_from_word('arrow')
      assert(expected.sort == actual.sort)

      expected = %w(carr arro rrot rots)
      actual = get_sequences_from_word('carrots')
      assert(expected.sort == actual.sort)

      expected = %w(carr)
      actual = get_sequences_from_word('carr')
      assert(expected.sort == actual.sort)

      expected = %w()
      actual = get_sequences_from_word('Car')
      assert(expected.sort == actual.sort)

    end

    def test_process_word
      sequences = %w(carr give rots rows rrot rrow)
      words = %w(carrots give carrots arrows carrots arrows)
      @words.each do |word|
        process_word(@pruned,@candidates, word)
      end

      sorted_seqs = @candidates.keys.sort
      actual_words = sorted_seqs.each_with_object([]) do |seq, ar |
        ar << @candidates[seq]
      end

      assert(sorted_seqs == sequences)
      assert(words == actual_words)
    end

  end

  Test::Unit::UI::Console::TestRunner.run(SeqTest)

end
