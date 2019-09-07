module Worlds
  class Base < Rubuild::Texture
    attr_accessor :grid_chunks, :grid_chunks_yxz, :grid_chunks_xzy

    def initialize
      @grid_chunks = {}
      @grid_chunks_yxz = {}
      @grid_chunks_xzy = {}
    end

    def find_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      @grid_chunks.dig(grid_chunk_z, grid_chunk_y, grid_chunk_x)
    end

    def find_or_initialize_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      @grid_chunks[grid_chunk_z] ||= {}
      @grid_chunks[grid_chunk_z][grid_chunk_y] ||= {}
      @grid_chunks[grid_chunk_z][grid_chunk_y][grid_chunk_x] ||= (
        grid_chunk = GridChunk.new(
          world: self,
          grid_chunk_x: grid_chunk_x,
          grid_chunk_y: grid_chunk_y,
          grid_chunk_z: grid_chunk_z
        )

        @grid_chunks_yxz[grid_chunk_y] ||= {}
        @grid_chunks_yxz[grid_chunk_y][grid_chunk_x] ||= {}
        @grid_chunks_yxz[grid_chunk_y][grid_chunk_x][grid_chunk_z] = grid_chunk

        @grid_chunks_xzy[grid_chunk_x] ||= {}
        @grid_chunks_xzy[grid_chunk_x][grid_chunk_z] ||= {}
        @grid_chunks_xzy[grid_chunk_x][grid_chunk_z][grid_chunk_y] = grid_chunk

        grid_chunk
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
      # drawn = Worlds::Base.memoized! :draw do
      #   # $app.internal.bm.report 'Drawing World...' do
      #     Rubuild::Texture.new_from_render(
      #       width: $app.window.width,
      #       height: $app.window.height
      #     ) do
      # already_drawn_xy = Set.new

            @grid_chunks.sort_by(&:first).reverse_each do |grid_chunk_z, h|
            # Parallel.each(@grid_chunks.sort_by(&:first).reverse, in_threads: 8) do |grid_chunk_z, h|
              h.sort_by(&:first).each do |grid_chunk_y, h|
                h.sort_by(&:first).each do |grid_chunk_x, grid_chunk|

                  (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
                    grid_chunk.pixel_x,
                    grid_chunk.pixel_y,
                    grid_chunk.pixel_z
                  )

                  # unless already_drawn_xy.include? [x_grid_chunk_2_5d, y_grid_chunk_2_5d]
                    # already_drawn_xy << [x_grid_chunk_2_5d, y_grid_chunk_2_5d]

                    grid_chunk_rendered = grid_chunk.render

                    grid_chunk_rendered.draw(
                      x: x_grid_chunk_2_5d,
                      y: y_grid_chunk_2_5d
                    )
                  # end
                end
              end
            end
      #     end
      #   # end
      # end

      # chunks_to_be_reblitted = {}
      #
      # if $app&.temp&.changed_grid_chunks&.any?
      #   # drawn = Worlds::Base.rememoized! :draw do
      #   #   Rubuild::Texture.new_from_render(
      #   #     width: $app.window.width,
      #   #     height: $app.window.height
      #   #   ) do
      #   #     drawn.draw(x: 0, y: 0)
      #   # puts $app.temp.changed_grid_chunks.deep_map_values.size
      #
      #       $app.temp.changed_grid_chunks.sort_by(&:first).reverse_each do |grid_chunk_z, h|
      #         h.sort_by(&:first).each do |grid_chunk_y, h|
      #           h.sort_by(&:first).each do |grid_chunk_x, changed_grid_chunk|
      #             # drawn.update_from_render do
      #               grid_chunk_rendered = rememoized!(:draw, changed_grid_chunk) { changed_grid_chunk.render }
      #               # chunks_to_be_reblitted.dig_set(grid_chunk_z, grid_chunk_y, grid_chunk_x, with: changed_grid_chunk)
      #
      #               lookahead = 10
      #
      #               (0..lookahead).each do |n|
      #                 grid_chunk_below_behind = find_grid_chunk(
      #                   grid_chunk_z: grid_chunk_z + n,
      #                   grid_chunk_y: grid_chunk_y - n,
      #                   grid_chunk_x: grid_chunk_x
      #                 )
      #
      #                 if grid_chunk_below_behind
      #                   chunks_to_be_reblitted.dig_set(
      #                     grid_chunk_below_behind.grid_chunk_z,
      #                     grid_chunk_below_behind.grid_chunk_y,
      #                     grid_chunk_below_behind.grid_chunk_x,
      #                     with: grid_chunk_below_behind
      #                   )
      #                 end
      #
      #                 grid_chunk_behind = find_grid_chunk(
      #                   grid_chunk_z: grid_chunk_z + n,
      #                   grid_chunk_y: grid_chunk_y - n + 1,
      #                   grid_chunk_x: grid_chunk_x
      #                 )
      #
      #                 if grid_chunk_behind
      #                   chunks_to_be_reblitted.dig_set(
      #                     grid_chunk_behind.grid_chunk_z,
      #                     grid_chunk_behind.grid_chunk_y,
      #                     grid_chunk_behind.grid_chunk_x,
      #                     with: grid_chunk_behind
      #                   )
      #                 end
      #               end
      #
      #               # look for all grid chunks below and behind
      #               (changed_grid_chunk.grid_chunk_z..$app.state.camera.visible_below_edge_grid_chunk_z).to_a.reverse.each do |_grid_chunk_z|
      #                 # (_grid_chunk_y..$app.state.camera.visible_above_edge_grid_chunk_z).each do |
      #                 (changed_grid_chunk.grid_chunk_y..$app.state.camera.visible_front_edge_grid_chunk_y).to_a.each do |_grid_chunk_y|
      #                   current_grid_chunk = find_grid_chunk(
      #                     grid_chunk_z: _grid_chunk_z,
      #                     grid_chunk_y: _grid_chunk_y,
      #                     grid_chunk_x: grid_chunk_x
      #                   )
      #
      #                   if current_grid_chunk
      #                     chunks_to_be_reblitted.dig_set(_grid_chunk_z, _grid_chunk_y, grid_chunk_x, with: current_grid_chunk)
      #                   end
      #                 end
      #               end
      #
      #               # (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      #               #   grid_chunk.pixel_x,
      #               #   grid_chunk.pixel_y,
      #               #   grid_chunk.pixel_z
      #               # )
      #               #
      #               # grid_chunk_rendered.draw(
      #               #   x: x_grid_chunk_2_5d,
      #               #   y: y_grid_chunk_2_5d
      #               # )
      #             # end
      #           end
      #         end
      #       end
      #   #   end
      #   # end
      # end
      #
      # if chunks_to_be_reblitted.any?
      #   drawn = Worlds::Base.rememoized! :draw do
      #     Rubuild::Texture.new_from_render(
      #       width: $app.window.width,
      #       height: $app.window.height
      #     ) do
      #       drawn.draw(x: 0, y: 0)
      #
      #       chunks_to_be_reblitted.sort_by(&:first).reverse_each do |grid_chunk_z, h|
      #         h.sort_by(&:first).each do |grid_chunk_y, h|
      #           h.sort_by(&:first).each do |grid_chunk_x, grid_chunk|
      #             grid_chunk_rendered = memoized!(:draw, grid_chunk) { grid_chunk.render }
      #
      #             (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      #               grid_chunk.pixel_x,
      #               grid_chunk.pixel_y,
      #               grid_chunk.pixel_z
      #             )
      #
      #             grid_chunk_rendered.draw(
      #               x: x_grid_chunk_2_5d,
      #               y: y_grid_chunk_2_5d
      #             )
      #           end
      #         end
      #       end
      #     end
      #   end
      # end
      #
      #
      # # puts chunks_to_be_reblitted.deep_map_values.size
      #
      # # binding.pry
      #
      # drawn.draw(x: 0, y: 0)
      # drawn
      #
      # # @grid_chunks[$app.state.dirts[560].grid_chunk_z][$app.state.dirts[560].grid_chunk_y][$app.state.dirts[560].grid_chunk_x].tap do |grid_chunk|
      # #   memoized!(:draw, grid_chunk) do
      # #     rendered = grid_chunk.render
      # #
      # #     (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      # #       grid_chunk.pixel_x,
      # #       grid_chunk.pixel_y,
      # #       grid_chunk.pixel_z
      # #     )
      # #
      # #     rendered.draw(
      # #       x: x_grid_chunk_2_5d,
      # #       y: y_grid_chunk_2_5d
      # #     )
      # #     rendered
      # #   end
      # # end
      #
      # # @grid_chunks.reverse_each do |grid_chunk_z, h|
      # #   h.each do |grid_chunk_y, h|
      # #     h.each do |grid_chunk_x, grid_chunk|
      # #       memoized!(:draw, grid_chunk) do
      # #         rendered = grid_chunk.render
      # #
      # #         (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      # #           grid_chunk.pixel_x,
      # #           grid_chunk.pixel_y,
      # #           grid_chunk.pixel_z
      # #         )
      # #
      # #         rendered.draw(
      # #           x: x_grid_chunk_2_5d,
      # #           y: y_grid_chunk_2_5d
      # #         )
      # #         rendered
      # #       end
      # #     end
      # #   end
      # # end
      #
      # # @grid_chunks[$app.state.dirts[560].grid_chunk_z][$app.state.dirts[560].grid_chunk_y][$app.state.dirts[560].grid_chunk_x].tap do |grid_chunk|
      # #   memoized!(:draw, grid_chunk) do
      # #     rendered = grid_chunk.render
      # #
      # #     (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
      # #       grid_chunk.pixel_x,
      # #       grid_chunk.pixel_y,
      # #       grid_chunk.pixel_z
      # #     )
      # #
      # #     rendered.draw(
      # #       x: x_grid_chunk_2_5d,
      # #       y: y_grid_chunk_2_5d
      # #     )
      # #     rendered
      # #   end
      # # end
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
require_relative 'camera'
