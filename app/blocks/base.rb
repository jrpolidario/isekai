module Blocks
  class Base
    include SuperCallbacks

    attr_accessor :world, :x, :y, :z, :textures, :uuid

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

    BORDER_COLOR = [32, 32, 32, 96]

    delegate(
      :grid_block_above, :grid_block_below,
      :grid_block_left, :grid_block_right,
      :grid_block_front, :grid_block_behind,
      :grid_blocks_surrounding, :grid_blocks_surrounding_objects,
      to: :grid_block
    )

    %i[x= y= z=].each do |m|
      before m do
        grid_blocks_surrounding_objects.each do |uuid, object|
          world.unmemoized!(:draw, object.grid_chunk)
        end

        grid_block.remove_from_objects(self)
      end

      after m do
        grid_block.add_to_objects(self)

        grid_blocks_surrounding_objects.each do |uuid, object|
          world.unmemoized!(:draw, object.grid_chunk)
        end
      end
    end

    def size
      Worlds::GridBlock::SIZE
    end

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

      grid_block.add_to_objects(self)
    end

    def render
      Blocks::Base.memoized!(
        :render,
        top_texture,
        bot_texture
      ) do
        Rubuild::Texture.new_from_render(
          width: size,
          height: size
        ) do
          top_texture.draw(x: 0, y: 0, width: size, height: size / 2)
          # $app.sdl_renderer.draw_color = [32, 32, 32, 32]
          # $app.sdl_renderer.draw_rect(SDL2::Rect.new(0, 0, size, size / 2))

          bot_texture.draw(x: 0, y: size / 2, width: size, height: size / 2)
          # $app.sdl_renderer.draw_color = [32, 32, 32, 32]
          # $app.sdl_renderer.draw_rect(SDL2::Rect.new(0, size / 2, size, size / 2))
        end
      end

      # TODO
      # if ([0, 1, 3, 4].include? grid_block_z)
      #   texture.sdl_texture.alpha_mod = 128
      #   texture.sdl_texture.color_mod = [128, 128, 128]
      # end
    end

    def draw(x: self.x, y: self.y, z: self.z)
      (x_2_5d, y_2_5d) = ::Helpers::Maths.to_2_5d(x, y, z)
      render.draw(x: x_2_5d, y: y_2_5d)
    end

    def top_texture
      # draw 4 corners of "top" block

      # start with everything assumed to be without any contact with any block
      texture_for_0xxx = TEXTURE_TOP_0XXX # lower left
      texture_for_x0xx = TEXTURE_TOP_X0XX # top left
      texture_for_xx0x = TEXTURE_TOP_XX0X # top right
      texture_for_xxx0 = TEXTURE_TOP_XXX0 # lower right

      should_draw_lines = Array.new(8, true)

      if !grid_block_above.objects.empty?
        texture_for_0xxx = TEXTURE_TOP_XXXX
        texture_for_x0xx = TEXTURE_TOP_XXXX
        texture_for_xx0x = TEXTURE_TOP_XXXX
        texture_for_xxx0 = TEXTURE_TOP_XXXX
        should_draw_lines = [false, false, false, false, false, false, false, false]
      else
        if !grid_block_left.objects.empty?
          should_draw_lines[0] = false
          should_draw_lines[1] = false
          texture_for_0xxx = TEXTURE_TOP_XXXX
          texture_for_x0xx = TEXTURE_TOP_XXXX
        end

        if !grid_block_behind.objects.empty?
          should_draw_lines[2] = false
          should_draw_lines[3] = false
          texture_for_x0xx = TEXTURE_TOP_XXXX
          texture_for_xx0x = TEXTURE_TOP_XXXX
        end

        if !grid_block_right.objects.empty?
          should_draw_lines[4] = false
          should_draw_lines[5] = false
          texture_for_xx0x = TEXTURE_TOP_XXXX
          texture_for_xxx0 = TEXTURE_TOP_XXXX
        end

        if !grid_block_front.objects.empty?
          should_draw_lines[6] = false
          should_draw_lines[7] = false
          texture_for_0xxx = TEXTURE_TOP_XXXX
          texture_for_xxx0 = TEXTURE_TOP_XXXX
        end
      end

      Blocks::Base.memoized!(
        :top_texture,
        *@textures.values_at(texture_for_0xxx, texture_for_x0xx, texture_for_xx0x, texture_for_xxx0),
        *should_draw_lines
      ) do
        Rubuild::Texture.new_from_render(
          width: size,
          height: size / 2
        ) do
          @textures[texture_for_0xxx].draw(x: 0, y: size / 4, width: size / 2, height: size / 4)
          @textures[texture_for_x0xx].draw(x: 0, y: 0, width: size / 2, height: size / 4)
          @textures[texture_for_xx0x].draw(x: size / 2, y: 0, width: size / 2, height: size / 4)
          @textures[texture_for_xxx0].draw(x: size / 2, y: size / 4, width: size / 2, height: size / 4)

          $app.sdl_renderer.draw_blend_mode = SDL2::BlendMode::BLEND
          $app.sdl_renderer.draw_color = BORDER_COLOR

          $app.sdl_renderer.draw_line(       0,       size / 4,            0,     (size / 2) - 1) if should_draw_lines[0]
          $app.sdl_renderer.draw_line(       0,              0,            0,           size / 4) if should_draw_lines[1]

          $app.sdl_renderer.draw_line(       0,              0,     size / 2,                  0) if should_draw_lines[2]
          $app.sdl_renderer.draw_line(size / 2,              0,     size - 1,                  0) if should_draw_lines[3]

          $app.sdl_renderer.draw_line(size - 1,              0,     size - 1,     (size / 4)    ) if should_draw_lines[4]
          $app.sdl_renderer.draw_line(size - 1,       size / 4,     size - 1,     (size / 2) - 1) if should_draw_lines[5]

          $app.sdl_renderer.draw_line(size / 2, (size / 2) - 1,     size - 1,     (size / 2) - 1) if should_draw_lines[6]
          $app.sdl_renderer.draw_line(       0, (size / 2) - 1,     size / 2,     (size / 2) - 1) if should_draw_lines[7]
        end
      end
    end

    def grid_chunk
      world.find_or_initialize_grid_chunk(grid_chunk_z: grid_chunk_z, grid_chunk_y: grid_chunk_y, grid_chunk_x: grid_chunk_x)
    end

    def grid_block
      world.find_or_initialize_grid_block(grid_block_z: grid_block_z, grid_block_y: grid_block_y, grid_block_x: grid_block_x)
    end

    def bot_texture
      # draw 4 corners of "bot" block

      # start with everything assumed to be without any contact with any block
      texture_for_0xxx = TEXTURE_BOT_0X # lower left
      texture_for_x0xx = TEXTURE_BOT_XX # top left # constant
      texture_for_xx0x = TEXTURE_BOT_XX # top right # constant
      texture_for_xxx0 = TEXTURE_BOT_X0 # lower right

      should_draw_lines = Array.new(8, true)

      should_draw_lines[2] = false # always should have no border
      should_draw_lines[3] = false # always should have no border

      if !grid_block_below.objects.empty?
        texture_for_0xxx = TEXTURE_BOT_XX
        texture_for_xxx0 = TEXTURE_BOT_XX
        should_draw_lines[6] = false
        should_draw_lines[7] = false
      end

      if !grid_block_left.objects.empty?
        should_draw_lines[0] = false
        should_draw_lines[1] = false
        texture_for_0xxx = TEXTURE_BOT_XX
      end

      if !grid_block_right.objects.empty?
        should_draw_lines[4] = false
        should_draw_lines[5] = false
        texture_for_xxx0 = TEXTURE_BOT_XX
      end

      if !grid_block_front.objects.empty?
        should_draw_lines[6] = false
        should_draw_lines[7] = false
        texture_for_0xxx = TEXTURE_BOT_XX
        texture_for_xxx0 = TEXTURE_BOT_XX
      end

      Blocks::Base.memoized!(
        :bot_texture,
        *@textures.values_at(texture_for_0xxx, texture_for_x0xx, texture_for_xx0x, texture_for_xxx0),
        *should_draw_lines,
      ) do
        Rubuild::Texture.new_from_render(
          width: size,
          height: size / 2
        ) do
          @textures[texture_for_0xxx].draw(x: 0, y: size / 4, width: size / 2, height: size / 4)
          @textures[texture_for_x0xx].draw(x: 0, y: 0, width: size / 2, height: size / 4)
          @textures[texture_for_xx0x].draw(x: size / 2, y: 0, width: size / 2, height: size / 4)
          @textures[texture_for_xxx0].draw(x: size / 2, y: size / 4, width: size / 2, height: size / 4)

          $app.sdl_renderer.draw_blend_mode = SDL2::BlendMode::BLEND
          $app.sdl_renderer.draw_color = BORDER_COLOR

          $app.sdl_renderer.draw_line(       0,       size / 4,            0,     (size / 2) - 1) if should_draw_lines[0]
          $app.sdl_renderer.draw_line(       0,              0,            0,           size / 4) if should_draw_lines[1]

          $app.sdl_renderer.draw_line(       0,              0,     size / 2,                  0) if should_draw_lines[2]
          $app.sdl_renderer.draw_line(size / 2,              0,     size - 1,                  0) if should_draw_lines[3]

          $app.sdl_renderer.draw_line(size - 1,              0,     size - 1,     (size / 4)    ) if should_draw_lines[4]
          $app.sdl_renderer.draw_line(size - 1,       size / 4,     size - 1,     (size / 2) - 1) if should_draw_lines[5]

          $app.sdl_renderer.draw_line(size / 2, (size / 2) - 1,     size - 1,     (size / 2) - 1) if should_draw_lines[6]
          $app.sdl_renderer.draw_line(       0, (size / 2) - 1,     size / 2,     (size / 2) - 1) if should_draw_lines[7]
        end
      end
    end

    def grid_block_z
      z / size
    end

    def grid_block_y
      y / size
    end

    def grid_block_x
      x / size
    end

    def grid_chunk_z
      grid_block_z / Worlds::GridChunk::SIZE
    end

    def grid_chunk_y
      grid_block_y / Worlds::GridChunk::SIZE
    end

    def grid_chunk_x
      grid_block_x / Worlds::GridChunk::SIZE
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
