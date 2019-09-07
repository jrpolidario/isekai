module Worlds
  class GridBlob
    SIZE = 4 # 7

    attr_reader :world, :grid_blob_x, :grid_blob_y, :grid_blob_z, :grid_chunks, :grid_chunks_yxz, :grid_chunks_xzy

    def initialize(world:, grid_blob_x:, grid_blob_y:, grid_blob_z:)
      @world = world
      @grid_blob_x = grid_blob_x
      @grid_blob_y = grid_blob_y
      @grid_blob_z = grid_blob_z
      @grid_chunks = {}
      @grid_chunks_yxz = {}
      @grid_chunks_xzy = {}
    end

    def find_or_initialize_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      @grid_chunks[grid_chunk_z] ||= {}
      @grid_chunks[grid_chunk_z][grid_chunk_y] ||= {}
      @grid_chunks[grid_chunk_z][grid_chunk_y][grid_chunk_x] ||= (
        grid_chunk = GridChunk.new(
          grid_blob: self,
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

    def find_grid_chunk(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:)
      @grid_chunks.dig(grid_chunk_z, grid_chunk_y, grid_chunk_x)
    end

    def remove_grid_chunk(grid_chunk)
      grid_chunk_z = grid_chunk.grid_chunk_z
      grid_chunk_y = grid_chunk.grid_chunk_y
      grid_chunk_x = grid_chunk.grid_chunk_x

      @grid_chunks[grid_chunk_z] || return
      @grid_chunks[grid_chunk_z][grid_chunk_y] || return
      @grid_chunks[grid_chunk_z][grid_chunk_y].delete(grid_chunk_x)
      @grid_chunks_yxz[grid_chunk_y][grid_chunk_x].delete(grid_chunk_z)
      @grid_chunks_xzy[grid_chunk_x][grid_chunk_z].delete(grid_chunk_y)
    end

    def grid_blob_above(step: 1)
      world.find_or_initialize_grid_blob(grid_blob_z: grid_blob_z - step, grid_blob_y: grid_blob_y, grid_blob_x: grid_blob_x)
    end

    def grid_blob_below(step: 1)
      world.find_or_initialize_grid_blob(grid_blob_z: grid_blob_z + step, grid_blob_y: grid_blob_y, grid_blob_x: grid_blob_x)
    end

    def grid_blob_left(step: 1)
      world.find_or_initialize_grid_blob(grid_blob_z: grid_blob_z, grid_blob_y: grid_blob_y, grid_blob_x: grid_blob_x - step)
    end

    def grid_blob_behind(step: 1)
      world.find_or_initialize_grid_blob(grid_blob_z: grid_blob_z, grid_blob_y: grid_blob_y - step, grid_blob_x: grid_blob_x)
    end

    def grid_blob_right(step: 1)
      world.find_or_initialize_grid_blob(grid_blob_z: grid_blob_z, grid_blob_y: grid_blob_y, grid_blob_x: grid_blob_x + step)
    end

    def grid_blob_front(step: 1)
      world.find_or_initialize_grid_blob(grid_blob_z: grid_blob_z, grid_blob_y: grid_blob_y + step, grid_blob_x: grid_blob_x)
    end

    # # callback!
    # def move_to_block(grid_chunk_z:, grid_chunk_y:, grid_chunk_x:, object:)
    #   block = find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
    #   block[object.uuid] = object
    # end

    def pixel_x
      grid_blob_x * SIZE * Worlds::GridChunk::SIZE * Worlds::GridBlock::SIZE
    end

    def pixel_y
      grid_blob_y * SIZE * Worlds::GridChunk::SIZE * Worlds::GridBlock::SIZE
    end

    def pixel_z
      grid_blob_z * SIZE * Worlds::GridChunk::SIZE * Worlds::GridBlock::SIZE
    end

    # TODO: use constant
    def grid_blob_pixels_size
      SIZE * Worlds::GridChunk::SIZE * Worlds::GridBlock::SIZE
    end

    def render
      $app.temp.rendered_grid_blobs_count ||= 0
      $app.temp.rendered_grid_blobs_count += 1

      world.memoized!(:render, self) do
        Rubuild::Texture.new_from_render(
          width: grid_blob_pixels_size * 1.5,
          height: grid_blob_pixels_size * 1.5
        ) do
          $app.temp.rerendered_grid_blobs_count ||= 0
          $app.temp.rerendered_grid_blobs_count += 1

          @grid_chunks.sort_by(&:first).reverse_each do |grid_chunk_z, h|
            h.sort_by(&:first).each do |grid_chunk_y, h|
              h.sort_by(&:first).each do |grid_chunk_x, grid_chunk|
                (x_grid_chunk_2_5d, y_grid_chunk_2_5d) = Helpers::Maths.to_2_5d(
                  grid_chunk.pixel_x - pixel_x,
                  grid_chunk.pixel_y - pixel_y,
                  grid_chunk.pixel_z - pixel_z
                )

                grid_chunk_rendered = grid_chunk.render

                grid_chunk_rendered.draw(
                  x: x_grid_chunk_2_5d,
                  y: y_grid_chunk_2_5d
                )
              end
            end
          end
        end
      end
    end

    def draw(x: pixel_x, y: pixel_y, z: pixel_z)
      (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(x, y, z)
      render.draw(x: x_2_5d, y: y_2_5d)
    end
  end
end
