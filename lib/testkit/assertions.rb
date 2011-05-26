module TestKit
  module Assertions
    def visible?(*assertions)
      assertions.each do |assertion|
        execute("findWithin", assertion) do |result|
          assert_equal(result, "true", "Could not find '#{assertion}' on the page")
        end
      end
    end
    
    def not_visible?(*assertions)
      assertions.each do |assertion|
        execute("findWithin", assertion) do |result|
          assert_nil(result, "Expected not to see '#{assertion}' on the page")
        end
      end
    end
  end
end
