module Worlds
  class Base < Rubuild::Texture
    attr_accessor :chunks_cached_draw_images
    attr_accessor :chunks

    def initialize
      @chunks = {}
      @chunks_cached_draw_images = {}
    end

    def find_or_initialize_chunk(chunk_z:, chunk_y:, chunk_x:)
      @chunks[chunk_z] ||= {}
      @chunks[chunk_z][chunk_y] ||= {}
      @chunks[chunk_z][chunk_y][chunk_x] ||= Chunk.new(chunk_x: chunk_x, chunk_y: chunk_y, chunk_z: chunk_z)
    end

    def draw
      chunks.sort.reverse.each do |chunk_z, h|
        h.sort.reverse.each do |chunk_y, h|
          h.sort.reverse.each do |chunk_x, chunk|
            @chunks_cached_draw_images[chunk_z] ||= {}
            @chunks_cached_draw_images[chunk_z][chunk_y] ||= {}

            if !@chunks_cached_draw_images[chunk_z][chunk_y][chunk_x]
              @chunks_cached_draw_images[chunk_z][chunk_y][chunk_x] = chunk.render
            end

            @chunks_cached_draw_images[chunk_z][chunk_y][chunk_x].draw
          end
        end
      end
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
require_relative 'chunk'
