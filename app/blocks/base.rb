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

      @textures[TEXTURE_TOP_XXXX] = Blocks::Base.memoized! :"textures_#{path = sampled_resolved_block_full_file_path('top_xxxx')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_TOP_0000] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('top_0000.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_TOP_0XXX] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('top_0xxx.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_TOP_X0XX] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('top_x0xx.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_TOP_XX0X] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('top_xx0x.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_TOP_XXX0] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('top_xxx0.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_BOT_XX] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('bot_xx.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_BOT_00] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('bot_00.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_BOT_0X] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('bot_0x.png')}" do
        Textures::Base.new(file_path: path)
      end
      @textures[TEXTURE_BOT_X0] = Blocks::Base.memoized! :"textures_#{path = resolved_block_full_file_path('bot_x0.png')}" do
        Textures::Base.new(file_path: path)
      end

      add_to_world_chunks
    end

    def render
      Blocks::Base.memoized!(
        :render,
        top_texture,
        bot_texture
      ) do
        Rubuild::Texture.new_from_render(
          width: SIZE,
          height: SIZE
        ) do
          top_texture.draw(x: 0, y: 0, width: SIZE, height: SIZE / 2)
          $app.sdl_renderer.draw_blend_mode = SDL2::BlendMode::BLEND
          $app.sdl_renderer.draw_color = [32, 32, 32, 32]
          $app.sdl_renderer.draw_rect(SDL2::Rect.new(0, 0, SIZE, SIZE / 2))

          bot_texture.draw(x: 0, y: SIZE / 2, width: SIZE, height: SIZE / 2)
          $app.sdl_renderer.draw_blend_mode = SDL2::BlendMode::BLEND
          $app.sdl_renderer.draw_color = [32, 32, 32, 32]
          $app.sdl_renderer.draw_rect(SDL2::Rect.new(0, SIZE / 2, SIZE, SIZE / 2))
        end
      end

      # TODO
      # if ([0, 1, 3, 4].include? block_z)
      #   texture.sdl_texture.alpha_mod = 128
      #   texture.sdl_texture.color_mod = [128, 128, 128]
      # end
    end

    def draw(x: self.x, y: self.y, z: self.z)
      (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(x, y, z)
      render.draw(x: x_2_5d, y: y_2_5d)
    end

    def top_texture
      block_above = world.find_or_initialize_block(block_z: block_z - 1, block_y: block_y, block_x: block_x)
      block_left = world.find_or_initialize_block(block_z: block_z, block_y: block_y, block_x: block_x - 1)
      block_behind = world.find_or_initialize_block(block_z: block_z, block_y: block_y - 1, block_x: block_x)
      block_right = world.find_or_initialize_block(block_z: block_z, block_y: block_y, block_x: block_x + 1)
      block_front = world.find_or_initialize_block(block_z: block_z, block_y: block_y + 1, block_x: block_x)

      # draw 4 corners of "top" block

      # start with everything assumed to be without any contact with any block
      texture_for_0xxx = TEXTURE_TOP_0XXX # lower left
      texture_for_x0xx = TEXTURE_TOP_X0XX # top left
      texture_for_xx0x = TEXTURE_TOP_XX0X # top right
      texture_for_xxx0 = TEXTURE_TOP_XXX0 # lower right

      if !block_above.empty?
        texture_for_0xxx = TEXTURE_TOP_XXXX
        texture_for_x0xx = TEXTURE_TOP_XXXX
        texture_for_xx0x = TEXTURE_TOP_XXXX
        texture_for_xxx0 = TEXTURE_TOP_XXXX
      else
        if !block_front.empty? || !block_left.empty?
          texture_for_0xxx = TEXTURE_TOP_XXXX
        end

        if !block_left.empty? || !block_behind.empty?
          texture_for_x0xx = TEXTURE_TOP_XXXX
        end

        if !block_behind.empty? || !block_right.empty?
          texture_for_xx0x = TEXTURE_TOP_XXXX
        end

        if !block_right.empty? || !block_front.empty?
          texture_for_xxx0 = TEXTURE_TOP_XXXX
        end
      end

      Blocks::Base.memoized!(
        :top_texture,
        @textures[texture_for_0xxx],
        @textures[texture_for_x0xx],
        @textures[texture_for_xx0x],
        @textures[texture_for_xxx0]
      ) do
        Rubuild::Texture.new_from_render(
          width: SIZE,
          height: SIZE / 2
        ) do
          @textures[texture_for_0xxx].draw(x: 0, y: SIZE / 4, width: SIZE / 2, height: SIZE / 4)
          @textures[texture_for_x0xx].draw(x: 0, y: 0, width: SIZE / 2, height: SIZE / 4)
          @textures[texture_for_xx0x].draw(x: SIZE / 2, y: 0, width: SIZE / 2, height: SIZE / 4)
          @textures[texture_for_xxx0].draw(x: SIZE / 2, y: SIZE / 4, width: SIZE / 2, height: SIZE / 4)
        end
      end
    end

    def bot_texture
      block_below = world.find_or_initialize_block(block_z: block_z + 1, block_y: block_y, block_x: block_x)
      block_left = world.find_or_initialize_block(block_z: block_z, block_y: block_y, block_x: block_x - 1)
      block_behind = world.find_or_initialize_block(block_z: block_z, block_y: block_y - 1, block_x: block_x)
      block_right = world.find_or_initialize_block(block_z: block_z, block_y: block_y, block_x: block_x + 1)
      block_front = world.find_or_initialize_block(block_z: block_z, block_y: block_y + 1, block_x: block_x)

      # draw 4 corners of "bot" block

      # start with everything assumed to be without any contact with any block
      texture_for_0xxx = TEXTURE_BOT_0X # lower left
      texture_for_x0xx = TEXTURE_BOT_XX # top left # constant
      texture_for_xx0x = TEXTURE_BOT_XX # top right # constant
      texture_for_xxx0 = TEXTURE_BOT_X0 # lower right

      if !block_below.empty?
        texture_for_0xxx = TEXTURE_BOT_XX
        texture_for_xxx0 = TEXTURE_BOT_XX
      else
        if !block_front.empty? || !block_left.empty?
          texture_for_0xxx = TEXTURE_BOT_XX
        end

        if !block_right.empty? || !block_front.empty?
          texture_for_xxx0 = TEXTURE_BOT_XX
        end
      end

      Blocks::Base.memoized!(
        :bot_texture,
        @textures[texture_for_0xxx],
        @textures[texture_for_x0xx],
        @textures[texture_for_xx0x],
        @textures[texture_for_xxx0]
      ) do
        Rubuild::Texture.new_from_render(
          width: SIZE,
          height: SIZE / 2
        ) do
          @textures[texture_for_0xxx].draw(x: 0, y: SIZE / 4, width: SIZE / 2, height: SIZE / 4)
          @textures[texture_for_x0xx].draw(x: 0, y: 0, width: SIZE / 2, height: SIZE / 4)
          @textures[texture_for_xx0x].draw(x: SIZE / 2, y: 0, width: SIZE / 2, height: SIZE / 4)
          @textures[texture_for_xxx0].draw(x: SIZE / 2, y: SIZE / 4, width: SIZE / 2, height: SIZE / 4)
        end
      end
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
      Blocks::Base.memoized!(:"resolved_block_full_file_path_#{file_path}") do
        if File.exist?(file_path)
          file_path
        elsif (
          (full_app_directory_shared_path = File.join(RUBUILD_PATH, 'app', 'textures', 'shared', file_path)) &&
          (File.exist? full_app_directory_shared_path)
        )
          full_app_directory_shared_path
        elsif (
          (app_directory_path = self.class.name.split('::').map(&:underscore)) &&
          (full_app_directory_path = File.join(RUBUILD_PATH, 'app', *app_directory_path, file_path)) &&
          (File.exist? full_app_directory_path)
        )
          full_app_directory_path
        else
          raise ArgumentError, "file does not exist: #{full_app_directory_path}"
        end
      end
    end

    def sampled_resolved_block_full_file_path(dir_path)
      Blocks::Base.memoized!(:"sampled_resolved_block_full_file_path_cache_#{dir_path}") do
        resolved_dir_path = resolved_block_full_file_path(dir_path)
        Dir[File.join(resolved_dir_path, '*')]
      end.sample
    end
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
