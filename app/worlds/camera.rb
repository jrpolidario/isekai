module Worlds
  class Camera
    attr_accessor :x, :y, :z, :rotation, :visible_grid_blocks_height

    # 8 chunks height
    def initialize(
      rotation: 0,
      visible_grid_blocks_height: 2 * $app.window.height / GridBlock::SIZE,
      visible_grid_blocks_length: 2 * $app.window.height / GridBlock::SIZE,
      visible_grid_blocks_width: $app.window.width / GridBlock::SIZE
    )
      @x = x
      @y = y
      @z = z
      @rotation = rotation
      @visible_grid_blocks_height = visible_grid_blocks_height
      @visible_grid_blocks_width = visible_grid_blocks_width
      @visible_grid_blocks_length = visible_grid_blocks_length
    end

    def visible_above_edge_grid_block_z
      (z / GridBlock::SIZE) - (@visible_grid_blocks_height / 2)
    end

    def visible_below_edge_grid_block_z
      (z / GridBlock::SIZE) + (@visible_grid_blocks_height / 2)
    end

    def visible_behind_edge_grid_block_y
      (y / GridBlock::SIZE) - (@visible_grid_blocks_length / 2)
    end

    def visible_front_edge_grid_block_y
      (y / GridBlock::SIZE) + (@visible_grid_blocks_length / 2)
    end

    def visible_left_edge_grid_block_x
      (x / GridBlock::SIZE) - (@visible_grid_blocks_width / 2)
    end

    def visible_right_edge_grid_block_x
      (x / GridBlock::SIZE) + (@visible_grid_blocks_width / 2)
    end

    def visible_above_edge_grid_chunk_z
      visible_above_edge_grid_block_z / GridChunk::SIZE
    end

    def visible_below_edge_grid_chunk_z
      visible_below_edge_grid_block_z / GridChunk::SIZE
    end

    def visible_front_edge_grid_chunk_y
      visible_front_edge_grid_block_y / GridChunk::SIZE
    end

    def visible_behind_edge_grid_chunk_y
      visible_behind_edge_grid_block_y / GridChunk::SIZE
    end

    def visible_right_edge_grid_chunk_x
      visible_right_edge_grid_block_x / GridChunk::SIZE
    end

    def visible_left_edge_grid_chunk_x
      visible_left_edge_grid_block_x / GridChunk::SIZE
    end
  end
end
