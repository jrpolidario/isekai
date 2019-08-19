module Blocks
  class Base
    include SuperCallbacks

    attr_accessor :world, :x, :y, :z, :textures, :uuid

    SIZE = 32

    TEXTURE_TOP_XXXX = 0
    TEXTURE_TOP_0000 = 1
    TEXTURE_TOP_0XXX = 2
    TEXTURE_TOP_X0XX = 3
    TEXTURE_TOP_XX0X = 4
    TEXTURE_TOP_XXX0 = 5
    TEXTURE_BOT_XX = 6
    TEXTURE_BOT_00 = 7
    TEXTURE_BOT_0X = 8
    TEXTURE_BOT_X0 = 9

    def initialize(world:, x:, y:, z:)
      @world = world
      @x = x
      @y = y
      @z = z
      @textures = []

      @uuid = SecureRandom.uuid

      @textures[TEXTURE_TOP_XXXX] = Textures::Base.new(file_path: resolved_block_full_file_path('top_xxxx.png'))
      @textures[TEXTURE_TOP_0000] = Textures::Base.new(file_path: resolved_block_full_file_path('top_0000.png'))
      @textures[TEXTURE_TOP_0XXX] = Textures::Base.new(file_path: resolved_block_full_file_path('top_0xxx.png'))
      @textures[TEXTURE_TOP_X0XX] = Textures::Base.new(file_path: resolved_block_full_file_path('top_x0xx.png'))
      @textures[TEXTURE_TOP_XX0X] = Textures::Base.new(file_path: resolved_block_full_file_path('top_xx0x.png'))
      @textures[TEXTURE_TOP_XXX0] = Textures::Base.new(file_path: resolved_block_full_file_path('top_xxx0.png'))
      @textures[TEXTURE_BOT_XX] = Textures::Base.new(file_path: resolved_block_full_file_path('bot_xx.png'))
      @textures[TEXTURE_BOT_00] = Textures::Base.new(file_path: resolved_block_full_file_path('bot_00.png'))
      @textures[TEXTURE_BOT_0X] = Textures::Base.new(file_path: resolved_block_full_file_path('bot_0x.png'))
      @textures[TEXTURE_BOT_X0] = Textures::Base.new(file_path: resolved_block_full_file_path('bot_x0.png'))

      add_to_world_chunks
    end

    def render
      Rubuild::Texture.new_from_render(
        width: SIZE,
        height: SIZE
      ) do
        top_texture.draw(x: 0, y: 0, width: SIZE, height: SIZE / 2)
        bot_texture.draw(x: 0, y: SIZE / 2, width: SIZE, height: SIZE / 2)
      end
    end

    def draw(x: self.x, y: self.y, z: self.z)
      (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(x, y, z)
      render.draw(x: x_2_5d, y: y_2_5d)
    end

    def top_texture
      @textures[TEXTURE_TOP_XXXX]
    end

    def bot_texture
      @textures[TEXTURE_BOT_XX]
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

      full_app_directory_shared_path = File.join(RUBUILD_PATH, 'app', 'textures', 'shared', file_path)
      return full_app_directory_shared_path if File.exist? full_app_directory_shared_path

      app_directory_path = self.class.name.split('::').map(&:underscore)
      full_app_directory_path = File.join(RUBUILD_PATH, 'app', *app_directory_path, file_path)
      return full_app_directory_path if File.exist? full_app_directory_path

      raise ArgumentError, "file does not exist: #{full_app_directory_path}"
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
