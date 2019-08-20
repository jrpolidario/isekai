module Worlds
  class Chunk
    SIZE = 4

    attr_accessor :chunk_x, :chunk_y, :chunk_z, :blocks

    def initialize(chunk_x:, chunk_y:, chunk_z:)
      @chunk_x = chunk_x
      @chunk_y = chunk_y
      @chunk_z = chunk_z
      @blocks = {}
    end

    def find_or_initialize_block(block_z:, block_y:, block_x:)
      @blocks[block_z] ||= {}
      @blocks[block_z][block_y] ||= {}
      @blocks[block_z][block_y][block_x] ||= {}
    end

    # # callback!
    # def move_to_block(block_z:, block_y:, block_x:, object:)
    #   block = find_or_initialize_block(block_z: block_z, block_y: block_y, block_x: block_x)
    #   block[object.uuid] = object
    # end

    def chunk_pixel_x
      chunk_x * SIZE * Blocks::Base::SIZE
    end

    def chunk_pixel_y
      chunk_y * SIZE * Blocks::Base::SIZE
    end

    def chunk_pixel_z
      chunk_z * SIZE * Blocks::Base::SIZE
    end

    # TODO: use constant
    def chunk_pixels_size
      SIZE * Blocks::Base::SIZE
    end

    def render
      # (chunk_2_5d_x, chunk_2_5d_y) = Helpers::Maths.to_2_5d(
      #   chunk_pixel_x,
      #   chunk_pixel_y,
      #   chunk_pixel_z
      # )

      Rubuild::Texture.new_from_render(
        width: chunk_pixels_size,
        height: chunk_pixels_size
      ) do
        blocks.sort.reverse.each do |block_z, h|
          h.sort.each do |block_y, h|
            h.sort.each do |block_x, h|
              h.each do |uuid, object|
                object.draw(
                  x: (block_x * Blocks::Base::SIZE) - chunk_pixel_x,
                  y: (block_y * Blocks::Base::SIZE) - chunk_pixel_y,
                  z: (block_z * Blocks::Base::SIZE) - chunk_pixel_z
                )
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

    def draw(x: chunk_pixel_x, y: chunk_pixel_y, z: chunk_pixel_z)
      (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(x, y, z)
      render.draw(x: x_2_5d, y: y_2_5d)
    end

    # def draw
    #   Rubuild::Texture.new_from_render(
    #     width: chunk_pixels_size,
    #     height: chunk_pixels_size
    #   ) do
    #     blocks.sort.reverse.each do |block_z, h|
    #       h.sort.reverse.each do |block_y, h|
    #         h.sort.reverse.each do |block_x, h|
    #           h.each do |uuid, object|
    #             object.draw(
    #               x: (block_x * Blocks::Base::SIZE) - chunk_pixel_x,
    #               y: (block_y * Blocks::Base::SIZE) - chunk_pixel_y,
    #               z: (block_z * Blocks::Base::SIZE) - chunk_pixel_z
    #             )
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
