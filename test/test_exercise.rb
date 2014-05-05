require 'test/unit'
require File.expand_path('../../lib/exercise.rb', __FILE__)

module Exercise
  class ContentTest < Test::Unit::TestCase
    def setup
      @data = {
        'seed' => 123,
        'meta' => {
          'title' => 'ttl1',
          'description' => 'desc1',
        },
        'exercises' => [
          {
            'subject' => 'section1',
            'questions' => [
              'question1 ___answer1___',
              'question2 ___answer1of2___ and ___answer2of2___'
            ]
          },
          {
            'subject' => 'section2',
            'questions' => [
              'question1 ___(answer1)___',
              'question2 ___(answer2)___'
            ]
          }
        ]
      }
    end

    def test_initialize
      content = Content.new(@data)

      assert_equal(123, content.seed)
      assert_equal('ttl1', content.meta[:title])
      assert_equal('desc1', content.meta[:description])
      assert_equal(2, content.exercises.length)

      assert_equal('section1', content.exercises[0][:subject])
      assert_equal(2, content.exercises[0][:questions].length)
      assert_equal('question1 ______', content.exercises[0][:questions][0][:question])
      assert_equal(['answer1'], content.exercises[0][:questions][0][:answer])
      assert_equal('question2 ______ and ______',
          content.exercises[0][:questions][1][:question])
      assert_equal(['answer1of2', 'answer2of2'],
          content.exercises[0][:questions][1][:answer])

      assert_equal(2, content.exercises[1][:questions].length)
      assert_equal('question1 ______', content.exercises[1][:questions][0][:question])
      assert_equal(['(answer1)'], content.exercises[1][:questions][0][:answer])
      assert_equal('question2 ______', content.exercises[1][:questions][1][:question])
      assert_equal(['(answer2)'], content.exercises[1][:questions][1][:answer])
    end

    def test_correct
      content = Content.new(@data)

      assert(!content.correct?(0, 0, []), 'question1')
      assert(content.correct?(0, 0, ['answer1']), 'question1')
      assert(content.correct?(0, 1, ['answer1of2', 'answer2of2']), 'question2')
      assert(content.correct?(1, 0, ['freeanswer']), 'question1')
      assert(content.correct?(1, 1, ['freeanswer']), 'question2')
      assert(content.correct?(1, 0, []), 'question1')
    end
  end
end
