module Worlds
  class GridBlock
    include SuperCallbacks

    SIZE = 16

    attr_reader :grid_chunk, :grid_block_x, :grid_block_y, :grid_block_z, :objects

    delegate :world, to: :grid_chunk

    # remove this from world if no longer has `objects`
    after :remove_from_objects do |object|
      grid_chunk.remove_grid_block(self) if @objects.empty?
    end

    def initialize(grid_chunk:, grid_block_x:, grid_block_y:, grid_block_z:)
      @grid_chunk = grid_chunk
      @grid_block_x = grid_block_x
      @grid_block_y = grid_block_y
      @grid_block_z = grid_block_z
      @objects = {}
    end

    def pixel_x
      grid_block_x * Worlds::GridBlock::SIZE
    end

    def pixel_y
      grid_block_y * Worlds::GridBlock::SIZE
    end

    def pixel_z
      grid_block_z * Worlds::GridBlock::SIZE
    end

    def render
      world.memoized!(:render, self) do
        Rubuild::Texture.new_from_render(
          width: SIZE,
          height: SIZE
        ) do
          @objects.sort_by { |object| [-object.z, object.y]}.each do |uuid, object|
            object.draw(
              x: object.x - pixel_x,
              y: object.y - pixel_y,
              z: object.z - pixel_z,
            )
          end
        end
      end
    end

    def draw(x: pixel_x, y: pixel_y, z: pixel_z)
      # (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(x, y, z)
      # render.draw(x: x_2_5d, y: y_2_5d)
      @objects.each do |uuid, object|
        # (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(
        #   object.x - grid_block.pixel_x,
        #   object.y - grid_block.pixel_y,
        #   object.y - grid_block.pixel_y
        # )

        object.draw(
          x: object.x - grid_chunk.pixel_x,
          y: object.y - grid_chunk.pixel_y,
          z: object.z - grid_chunk.pixel_z,
        )
      end
    end

    def add_to_objects(object)
      if @objects[object.uuid].nil?
        @objects[object.uuid] = object
      end
    end

    def remove_from_objects(object)
      @objects.delete(object.uuid)

      if @objects.empty?
        grid_chunk.remove_grid_block(self)
      end
    end

    def find_nearest_grid_block_above
      _vertical_grid_blocks = vertical_grid_blocks
      _vertical_grid_blocks[(_vertical_grid_blocks.index(self))..0].detect do |grid_block|
        grid_block.objects.any? if grid_block != self
      end

      # binding.pry if grid_block_x == 15 && grid_block_y == 15 && grid_block_z == 0
    end

    def find_nearest_grid_block_below
      _vertical_grid_blocks = vertical_grid_blocks
      _vertical_grid_blocks[(_vertical_grid_blocks.index(self))..(_vertical_grid_blocks.size)].detect do |grid_block|
        grid_block.objects.any? if grid_block != self
      end
    end

    def vertical_grid_blocks
      vertical_grid_chunks = [grid_chunk.grid_chunk_above, grid_chunk, grid_chunk.grid_chunk_below]
      vertical_grid_chunks.each_with_object({}) do |vertical_grid_chunk, hash|
        hash.merge! vertical_grid_chunk.grid_blocks_yxz.dig(grid_block_y, grid_block_x) || {}
      end.sort.map(&:second)
    end

    def grid_block_above(step: 1)
      grid_chunk.world.find_grid_block(grid_block_z: grid_block_z - step, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def grid_block_below(step: 1)
      grid_chunk.world.find_grid_block(grid_block_z: grid_block_z + step, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def grid_block_left(step: 1)
      grid_chunk.world.find_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x - step)
    end

    def grid_block_behind(step: 1)
      grid_chunk.world.find_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y - step, grid_block_x: grid_block_x)
    end

    def grid_block_right(step: 1)
      grid_chunk.world.find_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x + step)
    end

    def grid_block_front(step: 1)
      grid_chunk.world.find_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y + step, grid_block_x: grid_block_x)
    end

    def grid_blocks_surrounding(step: 1, include_self: true)
      grid_blocks = [
        grid_block_above(step: step),
        grid_block_below(step: step),
        grid_block_left(step: step),
        grid_block_behind(step: step),
        grid_block_right(step: step),
        grid_block_front(step: step)
      ]
      grid_blocks << self if include_self
      grid_blocks.compact
    end

    def grid_blocks_surrounding_objects(step: 1, include_self: true)
      grid_blocks_surrounding(step: step, include_self: include_self)&.map(&:objects)&.inject({}, :merge) || []
    end

    def pixel_x
      grid_block_x * SIZE
    end

    def pixel_y
      grid_block_y * SIZE
    end

    def pixel_z
      grid_block_z * SIZE
    end

    # def is_visible?
    #   grid_chunk.world.find_grid_block(grid_block_z: grid_block_z - step, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    #   grid_block_z +
    # end
  end
end
