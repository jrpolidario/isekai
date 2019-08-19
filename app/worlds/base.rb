module Worlds
  class Base < Rubuild::Texture
    attr_accessor :chunks_cached_draw_textures
    attr_accessor :chunks

    def initialize
      @chunks = {}
      @chunks_cached_draw_textures = {}
    end

    def find_or_initialize_chunk(chunk_z:, chunk_y:, chunk_x:)
      @chunks[chunk_z] ||= {}
      @chunks[chunk_z][chunk_y] ||= {}
      @chunks[chunk_z][chunk_y][chunk_x] ||= Chunk.new(chunk_x: chunk_x, chunk_y: chunk_y, chunk_z: chunk_z)
    end

    def draw
      chunks.sort.reverse.each do |chunk_z, h|
        h.sort.each do |chunk_y, h|
          h.sort.each do |chunk_x, chunk|
            @chunks_cached_draw_textures[chunk_z] ||= {}
            @chunks_cached_draw_textures[chunk_z][chunk_y] ||= {}

            if !@chunks_cached_draw_textures[chunk_z][chunk_y][chunk_x]
              @chunks_cached_draw_textures[chunk_z][chunk_y][chunk_x] = chunk.render
            end

            (x_chunk_2_5d, y_chunk_2_5d) = Helpers::Maths.to_2_5d(
              chunk.chunk_pixel_x,
              chunk.chunk_pixel_y,
              chunk.chunk_pixel_z
            )

            @chunks_cached_draw_textures[chunk_z][chunk_y][chunk_x].draw(
              x: x_chunk_2_5d,
              y: y_chunk_2_5d
            )
            
            # $app.sdl_renderer.present
            # $app.sdl_renderer.clear
            # binding.pry
          end
        end
      end
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
require_relative 'chunk'
