module Worlds
  class Base < Rubuild::Texture
    attr_accessor :grid_blobs, :grid_blobs_yxz, :grid_blobs_xzy

    def initialize
      @grid_blobs = {}
      @grid_blobs_yxz = {}
      @grid_blobs_xzy = {}
    end

    def find_grid_blob(grid_blob_z:, grid_blob_y:, grid_blob_x:)
      @grid_blobs.dig(grid_blob_z, grid_blob_y, grid_blob_x)
    end

    def find_or_initialize_grid_blob(grid_blob_z:, grid_blob_y:, grid_blob_x:)
      @grid_blobs[grid_blob_z] ||= {}
      @grid_blobs[grid_blob_z][grid_blob_y] ||= {}
      @grid_blobs[grid_blob_z][grid_blob_y][grid_blob_x] ||= (
        grid_blob = GridBlob.new(
          world: self,
          grid_blob_x: grid_blob_x,
          grid_blob_y: grid_blob_y,
          grid_blob_z: grid_blob_z
        )

        @grid_blobs_yxz[grid_blob_y] ||= {}
        @grid_blobs_yxz[grid_blob_y][grid_blob_x] ||= {}
        @grid_blobs_yxz[grid_blob_y][grid_blob_x][grid_blob_z] = grid_blob

        @grid_blobs_xzy[grid_blob_x] ||= {}
        @grid_blobs_xzy[grid_blob_x][grid_blob_z] ||= {}
        @grid_blobs_xzy[grid_blob_x][grid_blob_z][grid_blob_y] = grid_blob

        grid_blob
      )
    end

    def find_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      grid_blob_z = grid_chunk_z / GridBlob::SIZE
      grid_blob_y = grid_chunk_y / GridBlob::SIZE
      grid_blob_x = grid_chunk_x / GridBlob::SIZE
      grid_blob = find_grid_blob(grid_blob_z: grid_blob_z, grid_blob_y: grid_blob_y, grid_blob_x: grid_blob_x)
      grid_blob&.find_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
    end

    def find_or_initialize_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      grid_blob_z = grid_chunk_z / GridBlob::SIZE
      grid_blob_y = grid_chunk_y / GridBlob::SIZE
      grid_blob_x = grid_chunk_x / GridBlob::SIZE
      grid_blob = find_or_initialize_grid_blob(grid_blob_z: grid_blob_z, grid_blob_y: grid_blob_y, grid_blob_x: grid_blob_x)
      grid_blob.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
    end

    def find_grid_block(grid_block_z:, grid_block_y:, grid_block_x:)
      grid_chunk_z = grid_block_z / GridChunk::SIZE
      grid_chunk_y = grid_block_y / GridChunk::SIZE
      grid_chunk_x = grid_block_x / GridChunk::SIZE
      grid_chunk = find_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
      grid_chunk&.find_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def find_or_initialize_grid_block(grid_block_z:, grid_block_y:, grid_block_x:)
      grid_chunk_z = grid_block_z / GridChunk::SIZE
      grid_chunk_y = grid_block_y / GridChunk::SIZE
      grid_chunk_x = grid_block_x / GridChunk::SIZE
      grid_chunk = find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
      grid_chunk.find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def draw
      @grid_blobs.sort_by(&:first).reverse_each do |grid_blob_z, h|
        h.sort_by(&:first).each do |grid_blob_y, h|
          h.sort_by(&:first).each do |grid_blob_x, grid_blob|

            (x_grid_blob_2_5d, y_grid_blob_2_5d) = Helpers::Maths.to_2_5d(
              grid_blob.pixel_x,
              grid_blob.pixel_y,
              grid_blob.pixel_z
            )

            # unless already_drawn_xy.include? [x_grid_blob_2_5d, y_grid_blob_2_5d]
              # already_drawn_xy << [x_grid_blob_2_5d, y_grid_blob_2_5d]

              grid_blob_rendered = grid_blob.render

              grid_blob_rendered.draw(
                x: x_grid_blob_2_5d,
                y: y_grid_blob_2_5d
              )
            # end
          end
        end
      end
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
require_relative 'grid_blob'
require_relative 'grid_chunk'
require_relative 'grid_block'
require_relative 'camera'
