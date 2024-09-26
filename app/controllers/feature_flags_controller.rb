require 'splitclient-rb'

class FeatureFlagsController < ApplicationController
  before_action :initialize_split_client

  def show_treatments
    # Generate the letters and numbers arrays
    letters = ('a'..'z').to_a
    numbers = ('0'..'9').to_a

    # Create a 2D array to store the treatments
    @treatments_table = Array.new(26) { Array.new(10) }

    # Get treatments for each key and store in @treatments_table
    letters.each_with_index do |letter, letter_idx|
      numbers.each_with_index do |number, number_idx|
        key = "#{letter}#{number}"
        treatment = @split_client.get_treatment(key, 'new_onboarding') # Using @split_client here
        @treatments_table[letter_idx][number_idx] = treatment
      end
    end
  end

  private

  def initialize_split_client
    # Make sure you initialize the Split.io client with your API key
    api_key = File.read('split_api_key').strip

    split_factory = SplitIoClient::SplitFactory.new(api_key)
    @split_client = split_factory.client

    begin
      @split_client.block_until_ready
    rescue SplitIoClient::SDKBlockerTimeoutExpiredException
      puts 'SDK is not ready. Decide whether to continue or abort execution'
    end
  end
end

