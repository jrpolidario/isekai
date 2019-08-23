module Worlds
  class Base < Rubuild::Texture
    attr_accessor :grid_chunks

    def initialize
      @grid_chunks = {}
    end

    def find_or_initialize_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      @grid_chunks[grid_chunk_z] ||= {}
      @grid_chunks[grid_chunk_z][grid_chunk_y] ||= {}
      @grid_chunks[grid_chunk_z][grid_chunk_y][grid_chunk_x] ||= GridChunk.new(
        world: self,
        grid_chunk_x: grid_chunk_x,
        grid_chunk_y: grid_chunk_y,
        grid_chunk_z: grid_chunk_z
      )
    end

    def find_or_initialize_grid_block(grid_block_z:, grid_block_y:, grid_block_x:)
      grid_chunk_z = grid_block_z / GridChunk::SIZE
      grid_chunk_y = grid_block_y / GridChunk::SIZE
      grid_chunk_x = grid_block_x / GridChunk::SIZE
      grid_chunk = find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
      grid_chunk.find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def draw
      @grid_chunks.sort.reverse.each do |grid_chunk_z, h|
        h.sort.each do |grid_chunk_y, h|
          h.sort.each do |grid_chunk_x, grid_chunk|
            grid_chunk_render = memoized!(:draw, grid_chunk) { grid_chunk.render }

            (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
              grid_chunk.pixel_x,
              grid_chunk.pixel_y,
              grid_chunk.pixel_z
            )

            grid_chunk_render.draw(
              x: x_grid_chunk_2_5d,
              y: y_grid_chunk_2_5d
            )
          end
        end
      end
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
require_relative 'grid_chunk'
require_relative 'grid_block'
