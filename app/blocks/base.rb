module Blocks
  class Base
    include SuperCallbacks

    attr_accessor :world, :x, :y, :z, :images, :uuid

    SIZE = 32

    IMAGE_TOP_XXXX = 0
    IMAGE_TOP_0000 = 1
    IMAGE_TOP_0XXX = 2
    IMAGE_TOP_X0XX = 3
    IMAGE_TOP_XX0X = 4
    IMAGE_TOP_XXX0 = 5
    IMAGE_BOT_XX = 6
    IMAGE_BOT_00 = 7
    IMAGE_BOT_0X = 8
    IMAGE_BOT_X0 = 9

    def initialize(world:, x:, y:, z:)
      @world = world
      @x = x
      @y = y
      @z = z
      @images = []

      @uuid = SecureRandom.uuid

      @images[IMAGE_TOP_XXXX] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('top_xxxx.png'))
      @images[IMAGE_TOP_0000] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('top_0000.png'))
      @images[IMAGE_TOP_0XXX] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('top_0xxx.png'))
      @images[IMAGE_TOP_X0XX] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('top_x0xx.png'))
      @images[IMAGE_TOP_XX0X] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('top_xx0x.png'))
      @images[IMAGE_TOP_XXX0] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('top_xxx0.png'))
      @images[IMAGE_BOT_XX] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('bot_xx.png'))
      @images[IMAGE_BOT_00] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('bot_00.png'))
      @images[IMAGE_BOT_0X] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('bot_0x.png'))
      @images[IMAGE_BOT_X0] = Images::Base.new(width: SIZE, height: SIZE / 2, file_path: resolved_block_full_file_path('bot_x0.png'))

      add_to_world_chunks
    end

    def draw
      (top_image.x, top_image.y) = ::Helpers::Maths.to_2_5d(x, y, z)
      (bot_image.x, bot_image.y) = ::Helpers::Maths.to_2_5d(x, y, z + (SIZE / 2))

      top_image.draw
      bot_image.draw
    end

    def top_image
      @images[IMAGE_TOP_XXXX]
    end

    def bot_image
      @images[IMAGE_BOT_XX]
    end

    def block_z
      z / Blocks::Base::SIZE
    end

    def block_y
      y / Blocks::Base::SIZE
    end

    def block_x
      x / Blocks::Base::SIZE
    end

    def chunk_z
      block_z / Worlds::Chunk::SIZE
    end

    def chunk_y
      block_y / Worlds::Chunk::SIZE
    end

    def chunk_x
      block_x / Worlds::Chunk::SIZE
    end

    # def world_chunk_block
    #   world.chunks[chunk_z] ||= {}
    #   world.chunks[chunk_z][chunk_y] ||= {}
    #   world.chunks[chunk_z][chunk_y][chunk_x] ||= {}
    #   world.chunks[chunk_z][chunk_y][chunk_x][block_z] ||= {}
    #   world.chunks[chunk_z][chunk_y][chunk_x][block_z][block_y] ||= {}
    #   world.chunks[chunk_z][chunk_y][chunk_x][block_z][block_y][block_x] ||= {}
    # end

    def world_chunk_block
      chunk = world.find_or_initialize_chunk(chunk_z: chunk_z, chunk_y: chunk_y, chunk_x: chunk_x)
      block = chunk.find_or_initialize_block(block_z: block_z, block_y: block_y, block_x: block_x)
    end

    def add_to_world_chunks
      if world_chunk_block[uuid].nil?
        world_chunk_block[uuid] = self
      end
    end

    def remove_from_world_chunks
      world_chunk_block.delete(uuid)
    end

    private

    def resolved_block_full_file_path(file_path)
      return file_path if File.exist?(file_path)

      full_app_directory_shared_path = File.join(RUBUILD_PATH, 'app', 'images', 'shared', file_path)
      return full_app_directory_shared_path if File.exist? full_app_directory_shared_path

      app_directory_path = self.class.name.split('::').map(&:underscore)
      full_app_directory_path = File.join(RUBUILD_PATH, 'app', *app_directory_path, file_path)
      return full_app_directory_path if File.exist? full_app_directory_path

      raise ArgumentError, "file does not exist: #{full_app_directory_path}"
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
