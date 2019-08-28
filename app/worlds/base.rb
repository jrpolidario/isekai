module Worlds
  class Base < Rubuild::Texture
    attr_accessor :grid_chunks

    def initialize
      @grid_chunks = {}
    end

    def find_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      @grid_chunks.dig(grid_chunk_z, grid_chunk_y, grid_chunk_x)
    end

    def find_or_initialize_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      @grid_chunks.dig_or_set(
        grid_chunk_z, grid_chunk_y, grid_chunk_x,
        with: GridChunk.new(
          world: self,
          grid_chunk_x: grid_chunk_x,
          grid_chunk_y: grid_chunk_y,
          grid_chunk_z: grid_chunk_z
        )
      )
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
      drawn = Worlds::Base.memoized! :draw do
        # $app.internal.bm.report 'Drawing World...' do
          Rubuild::Texture.new_from_render(
            width: $app.window.width,
            height: $app.window.height
          ) do
            @grid_chunks.sort_by(&:first).reverse_each do |grid_chunk_z, h|
              h.sort_by(&:first).each do |grid_chunk_y, h|
                h.sort_by(&:first).each do |grid_chunk_x, grid_chunk|
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
        # end
      end

      if $app&.temp&.changed_grid_chunks&.any?
        drawn = Worlds::Base.rememoized! :draw do
          Rubuild::Texture.new_from_render(
            width: $app.window.width,
            height: $app.window.height
          ) do
            drawn.draw(x: 0, y: 0)

            $app.temp.changed_grid_chunks.sort_by(&:first).reverse_each do |grid_chunk_z, h|
              h.sort_by(&:first).each do |grid_chunk_y, h|
                h.sort_by(&:first).each do |grid_chunk_x, grid_chunk|
                  # drawn.update_from_render do
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
                  # end
                end
              end
            end
          end
        end
      end

      drawn.draw(x: 0, y: 0)
      drawn

      # @grid_chunks[$app.state.dirts[560].grid_chunk_z][$app.state.dirts[560].grid_chunk_y][$app.state.dirts[560].grid_chunk_x].tap do |grid_chunk|
      #   memoized!(:draw, grid_chunk) do
      #     rendered = grid_chunk.render
      #
      #     (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      #       grid_chunk.pixel_x,
      #       grid_chunk.pixel_y,
      #       grid_chunk.pixel_z
      #     )
      #
      #     rendered.draw(
      #       x: x_grid_chunk_2_5d,
      #       y: y_grid_chunk_2_5d
      #     )
      #     rendered
      #   end
      # end

      # @grid_chunks.reverse_each do |grid_chunk_z, h|
      #   h.each do |grid_chunk_y, h|
      #     h.each do |grid_chunk_x, grid_chunk|
      #       memoized!(:draw, grid_chunk) do
      #         rendered = grid_chunk.render
      #
      #         (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      #           grid_chunk.pixel_x,
      #           grid_chunk.pixel_y,
      #           grid_chunk.pixel_z
      #         )
      #
      #         rendered.draw(
      #           x: x_grid_chunk_2_5d,
      #           y: y_grid_chunk_2_5d
      #         )
      #         rendered
      #       end
      #     end
      #   end
      # end

      # @grid_chunks[$app.state.dirts[560].grid_chunk_z][$app.state.dirts[560].grid_chunk_y][$app.state.dirts[560].grid_chunk_x].tap do |grid_chunk|
      #   memoized!(:draw, grid_chunk) do
      #     rendered = grid_chunk.render
      #
      #     (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      #       grid_chunk.pixel_x,
      #       grid_chunk.pixel_y,
      #       grid_chunk.pixel_z
      #     )
      #
      #     rendered.draw(
      #       x: x_grid_chunk_2_5d,
      #       y: y_grid_chunk_2_5d
      #     )
      #     rendered
      #   end
      # end
    end

    # for debugging
    def all_grid_chunks
      hash = {}
      @grid_chunks.reverse_each do |grid_chunk_z, h|
        h.each do |grid_chunk_y, h|
          h.each do |grid_chunk_x, grid_chunk|
            hash[
              {
                grid_chunk_z: grid_chunk_z,
                grid_chunk_y: grid_chunk_y,
                grid_chunk_x: grid_chunk_x,
              }
            ] = grid_chunk
          end
        end
      end
      hash
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
require_relative 'grid_chunk'
require_relative 'grid_block'
