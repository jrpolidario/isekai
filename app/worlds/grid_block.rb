module Worlds
  class GridBlock
    SIZE = 16

    attr_reader :grid_chunk, :grid_block_x, :grid_block_y, :grid_block_z, :objects

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
      @objects.each do |uuid, object|
        object.draw(
          x: object.x - grid_chunk.pixel_x,
          y: object.y - grid_chunk.pixel_y,
          z: object.z - grid_chunk.pixel_z
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
    end

    def grid_block_above(step: 1)
      grid_chunk.world.find_or_initialize_grid_block(grid_block_z: grid_block_z - step, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def grid_block_below(step: 1)
      grid_chunk.world.find_or_initialize_grid_block(grid_block_z: grid_block_z + step, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def grid_block_left(step: 1)
      grid_chunk.world.find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x - step)
    end

    def grid_block_behind(step: 1)
      grid_chunk.world.find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y - step, grid_block_x: grid_block_x)
    end

    def grid_block_right(step: 1)
      grid_chunk.world.find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x + step)
    end

    def grid_block_front(step: 1)
      grid_chunk.world.find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y + step, grid_block_x: grid_block_x)
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
      grid_blocks
    end

    def grid_blocks_surrounding_objects(step: 1, include_self: true)
      grid_blocks_surrounding(step: step, include_self: include_self).map(&:objects).inject({}, :merge)
    end
  end
end
