module Worlds
  class GridChunk
    SIZE = 6 # 7

    attr_reader :world, :grid_chunk_x, :grid_chunk_y, :grid_chunk_z, :grid_blocks, :grid_blocks_yxz, :grid_blocks_xzy

    def initialize(world:, grid_chunk_x:, grid_chunk_y:, grid_chunk_z:)
      @world = world
      @grid_chunk_x = grid_chunk_x
      @grid_chunk_y = grid_chunk_y
      @grid_chunk_z = grid_chunk_z
      @grid_blocks = {}
      @grid_blocks_yxz = {}
      @grid_blocks_xzy = {}
    end

    def find_or_initialize_grid_block(grid_block_z:, grid_block_y:, grid_block_x:)
      @grid_blocks[grid_block_z] ||= {}
      @grid_blocks[grid_block_z][grid_block_y] ||= {}
      @grid_blocks[grid_block_z][grid_block_y][grid_block_x] ||= (
        grid_block = GridBlock.new(
          grid_chunk: self,
          grid_block_x: grid_block_x,
          grid_block_y: grid_block_y,
          grid_block_z: grid_block_z
        )

        @grid_blocks_yxz[grid_block_y] ||= {}
        @grid_blocks_yxz[grid_block_y][grid_block_x] ||= {}
        @grid_blocks_yxz[grid_block_y][grid_block_x][grid_block_z] = grid_block

        @grid_blocks_xzy[grid_block_x] ||= {}
        @grid_blocks_xzy[grid_block_x][grid_block_z] ||= {}
        @grid_blocks_xzy[grid_block_x][grid_block_z][grid_block_y] = grid_block

        grid_block
      )
    end

    def find_grid_block(grid_block_z:, grid_block_y:, grid_block_x:)
      @grid_blocks.dig(grid_block_z, grid_block_y, grid_block_x)
    end

    def remove_grid_block(grid_block)
      grid_block_z = grid_block.grid_block_z
      grid_block_y = grid_block.grid_block_y
      grid_block_x = grid_block.grid_block_x

      @grid_blocks[grid_block_z] || return
      @grid_blocks[grid_block_z][grid_block_y] || return
      @grid_blocks[grid_block_z][grid_block_y].delete(grid_block_x)
      @grid_blocks_yxz[grid_block_y][grid_block_x].delete(grid_block_z)
      @grid_blocks_xzy[grid_block_x][grid_block_z].delete(grid_block_y)
    end

    def grid_chunk_above(step: 1)
      world.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z - step, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
    end

    def grid_chunk_below(step: 1)
      world.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z + step, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
    end

    def grid_chunk_left(step: 1)
      world.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x - step)
    end

    def grid_chunk_behind(step: 1)
      world.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y - step, grid_chunk_x: grid_chunk_x)
    end

    def grid_chunk_right(step: 1)
      world.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x + step)
    end

    def grid_chunk_front(step: 1)
      world.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y + step, grid_chunk_x: grid_chunk_x)
    end

    # # callback!
    # def move_to_block(grid_block_z:, grid_block_y:, grid_block_x:, object:)
    #   block = find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    #   block[object.uuid] = object
    # end

    def pixel_x
      grid_chunk_x * SIZE * Worlds::GridBlock::SIZE
    end

    def pixel_y
      grid_chunk_y * SIZE * Worlds::GridBlock::SIZE
    end

    def pixel_z
      grid_chunk_z * SIZE * Worlds::GridBlock::SIZE
    end

    # TODO: use constant
    def grid_chunk_pixels_size
      SIZE * Worlds::GridBlock::SIZE
    end

    def render
      # (chunk_2_5d_x, chunk_2_5d_y) = Helpers::Maths.to_2_5d(
      #   pixel_x,
      #   pixel_y,
      #   pixel_z
      # )

      world.memoized!(:render, self) do
        Rubuild::Texture.new_from_render(
          width: grid_chunk_pixels_size * 1.5,
          height: grid_chunk_pixels_size * 1.5
        ) do
          # $app.sdl_renderer.draw_color = [0xA0, 0xA0, 0xA0]
          # $app.sdl_renderer.fill_rect(SDL2::Rect.new(0, 0, grid_chunk_pixels_size * 1.5, grid_chunk_pixels_size * 1.5))

          @grid_blocks.sort_by(&:first).reverse_each do |grid_block_z, h|
            h.sort_by(&:first).each do |grid_block_y, h|
              h.sort_by(&:first).each do |grid_block_x, grid_block|
                # (x_grid_block_2_5d, y_grid_block_2_5d) = Helpers::Maths.to_2_5d(
                #   grid_block.pixel_x - pixel_x,
                #   grid_block.pixel_y - pixel_y,
                #   grid_block.pixel_z - pixel_z
                # )
                #
                # # (pixel_x_grid_block_2_5d, pixel_y_grid_block_2_5d) = Helpers::Maths.to_2_5d(
                # #   grid_block.pixel_x,
                # #   grid_block.pixel_y,
                # #   grid_block.pixel_z
                # # )
                # #
                # # unless $app.temp.already_rendered_xy.has_key? [pixel_x_grid_block_2_5d.to_i, pixel_y_grid_block_2_5d.to_i]
                # #   $app.temp.already_rendered_xy[[pixel_x_grid_block_2_5d.to_i, pixel_y_grid_block_2_5d.to_i]] = true
                #
                #   grid_block_rendered = grid_block.render
                #
                #   grid_block_rendered.draw(
                #     x: x_grid_block_2_5d,
                #     y: y_grid_block_2_5d
                #   )
                # # end

                # (x_grid_block_2_5d, y_grid_block_2_5d) = Helpers::Maths.to_2_5d(
                #   grid_block.pixel_x - pixel_x,
                #   grid_block.pixel_y - pixel_y,
                #   grid_block.pixel_z - pixel_z
                # )

                grid_block.draw
              end
            end
          end
        end
      end

      # Textures::Base.new(
      #   # x: chunk_2_5d_x,
      #   # y: chunk_2_5d_y,
      #   width: draw_image_texture.width,
      #   height: draw_image_texture.height,
      #   texture: draw_image_texture
      # )
    end

    def draw(x: pixel_x, y: pixel_y, z: pixel_z)
      (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(x, y, z)
      render.draw(x: x_2_5d, y: y_2_5d)
    end

    # def draw
    #   Rubuild::Texture.new_from_render(
    #     width: grid_chunk_pixels_size,
    #     height: grid_chunk_pixels_size
    #   ) do
    #     blocks.sort.reverse.each do |grid_block_z, h|
    #       h.sort.reverse.each do |grid_block_y, h|
    #         h.sort.reverse.each do |grid_block_x, h|
    #           h.each do |uuid, object|
    #             object.draw(
    #               x: (grid_block_x * Worlds::GridBlock::SIZE) - pixel_x,
    #               y: (grid_block_y * Worlds::GridBlock::SIZE) - pixel_y,
    #               z: (grid_block_z * Worlds::GridBlock::SIZE) - pixel_z
    #             )
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
