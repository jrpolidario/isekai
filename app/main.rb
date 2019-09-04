Rubuild::Application.init!(name: 'Isekai')

Dir[File.join(__dir__, 'helpers', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '**', 'base.rb')].each { |file| require file }

# $app.internal.pool = Concurrent::FixedThreadPool.new(5) # 5 threads

$app.internal.threads = []

$app.state.world = Worlds::Default.new
$app.state.camera = Worlds::Camera.new

$app.state.fps = Texts::Default.new(x: 0, y: 0, color: :green)
$app.state.puts = Texts::Default.new(x: 50, y: $app.window.height - 114)

$app.state.dirts = []

reference_dirt = Blocks::Dirt01.new(world: $app.state.world)

Benchmark.bm do |bm|
  $app.internal.bm = bm

  bm.report 'Initializing Blocks...' do
    mid_block_x = ($app.window.width / Worlds::GridBlock::SIZE) / 2
    mid_block_y = ($app.window.height * 2 / Worlds::GridBlock::SIZE) / 2

    (0...5).to_a.each do |z|
      # $app.internal.threads << Thread.new do
        (0...($app.window.height * 2 / Worlds::GridBlock::SIZE)).to_a.each do |y|
        # $app.internal.pool.post do
        # $app.internal.threads << Thread.new do
          (0...($app.window.width / Worlds::GridBlock::SIZE)).to_a.each do |x|
            # if rand(3) >= 2
              if (
                !x.between?((mid_block_x - 2), (mid_block_x + 2)) &&
                !y.between?((mid_block_y - 2), (mid_block_y + 2))
              )
                dirt = reference_dirt.clone
                dirt.instance_eval do
                  @x = x * Worlds::GridBlock::SIZE
                  @y = y * Worlds::GridBlock::SIZE
                  @z = z * Worlds::GridBlock::SIZE
                  @uuid = SecureRandom.uuid.to_sym # Time.now.to_f
                  @textures[Blocks::Base::TEXTURE_TOP_XXXX] = Blocks::Base.memoized! :textures, (path = sampled_resolved_block_full_file_path('top_xxxx')) do
                    Textures::Base.new(file_path: path)
                  end
                end
                dirt.grid_block.add_to_objects(dirt)
                dirt.trace_casted_shadow
                dirt.cast_shadow
                $app.state.dirts << dirt


                # $app.state.dirts << Blocks::Dirt01.new!(
                #   world: $app.state.world,
                #   x: x * Worlds::GridBlock::SIZE,
                #   y: y * Worlds::GridBlock::SIZE,
                #   z: z * Worlds::GridBlock::SIZE
                # )
              end
            # end
          end
        end
      # end
    end

    # $app.internal.pool.wait_for_termination

    $app.state.dirts << Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 5 * Worlds::GridBlock::SIZE,
      y: 5 * Worlds::GridBlock::SIZE,
      z: -1 * Worlds::GridBlock::SIZE
    )

    $app.state.dirts << Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 6 * Worlds::GridBlock::SIZE,
      y: 5 * Worlds::GridBlock::SIZE,
      z: -1 * Worlds::GridBlock::SIZE
    )

    $app.state.dirts << Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 6 * Worlds::GridBlock::SIZE,
      y: 6 * Worlds::GridBlock::SIZE,
      z: -1 * Worlds::GridBlock::SIZE
    )

    $app.state.dirts << Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 10 * Worlds::GridBlock::SIZE,
      y: 10 * Worlds::GridBlock::SIZE,
      z: -1 * Worlds::GridBlock::SIZE
    )

    $app.state.dirts << Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 10 * Worlds::GridBlock::SIZE,
      y: 10 * Worlds::GridBlock::SIZE,
      z: -2 * Worlds::GridBlock::SIZE
    )

    $app.state.dirts << Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 11 * Worlds::GridBlock::SIZE,
      y: 10 * Worlds::GridBlock::SIZE,
      z: -1 * Worlds::GridBlock::SIZE
    )

    $app.state.dirts << Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 11 * Worlds::GridBlock::SIZE,
      y: 10 * Worlds::GridBlock::SIZE,
      z: -2 * Worlds::GridBlock::SIZE
    )

    $app.state.dirt2 = Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 15 * Worlds::GridBlock::SIZE,
      y: 15 * Worlds::GridBlock::SIZE,
      z: 0 * Worlds::GridBlock::SIZE
    )

    $app.state.dirt = Blocks::Dirt01.new!(
      world: $app.state.world,
      x: 15 * Worlds::GridBlock::SIZE,
      y: 15 * Worlds::GridBlock::SIZE,
      z: -6 * Worlds::GridBlock::SIZE
    )

    # ThreadsWait.all_waits(*$app.internal.threads)
  end

  # $app.state.player << Blocks::Player.new(
  #   world: $app.state.world,
  #   x: 10 * Worlds::GridBlock::SIZE,
  #   y: 10 * Worlds::GridBlock::SIZE,
  #   z: -1 * Worlds::GridBlock::SIZE
  # )

  # (0...($app.window.height * 2 / Worlds::GridBlock::SIZE)).to_a.reverse.each do |z|
  #   (0...1).to_a.each do |y|
  #     (0...1).to_a.each do |x|
  #       $app.state.dirts << Blocks::Dirt01.new(
  #         world: $app.state.world,
  #         x: x * Worlds::GridBlock::SIZE,
  #         y: y * Worlds::GridBlock::SIZE,
  #         z: z * Worlds::GridBlock::SIZE
  #       )
  #     end
  #   end
  # end

  # (0...1).to_a.reverse.each do |z|
  #   (0...6).to_a.reverse.each do |y|
  #     (0...6).to_a.each do |x|
  #       $app.state.dirts << Blocks::Dirt01.new(
  #         world: $app.state.world,
  #         x: x * Worlds::GridBlock::SIZE,
  #         y: y * Worlds::GridBlock::SIZE,
  #         z: z * Worlds::GridBlock::SIZE
  #       )
  #     end
  #   end
  # end


  # $app.state.dirts_cache = Images::Base.new(
  #   width: $app.window.width,
  #   height: $app.window.height
  # )
  #
  # $app.state.dirts_cache.singleton_class.define_method(:render_dirts_cache) do
  #   $app.state.dirts_cache.texture = Rubuild::Texture.new_from_render(
  #     width: $app.state.dirts_cache.width,
  #     height: $app.state.dirts_cache.height
  #   ) do
  #     $app.state.world.draw
  #   end
  # end

  # $app.state.dirts_cache.render_dirts_cache

  # $app.state.dirts.each do |dirt|
  #   %i[x= y= width= height= rotation= texture=].each do |method_name|
  #     dirt.after method_name do |arg|
  #       if instance_variable_changed? "@#{method_name[0..-2]}"
  #         $app.state.dirts_cache.render_dirts_cache
  #       end
  #     end
  #   end
  # end

  # $app.state.world.draw

  # $app.state.world.chunks_cached_draw_images[0][0][1].x = 0
  # $app.state.world.chunks_cached_draw_images[0][0][1].y = 0

  # Thread.new do
  #   $app.state.world.draw
  # end
  # $app.internal.pool.post do
  #   $app.state.world.draw
  # end

  # bm.report 'Drawing World...' do
  #   $app.state.world.draw
  # end
end

$app.tick do
  $app.temp.changed_grid_chunks = {}

  $app.sdl_renderer.draw_color = [0xA0, 0xA0, 0xA0]

  #
  # $app.state.dirt.draw

  # $app.internal.pool.post do
    # $app.state.dirts.map(&:draw)
  # end
  # $app.internal.pool.post do
  # $app.state.world.draw#(only_cached: true)
  # end
  # $app.state.world.draw(only_cached: true)

  # binding.pry

  # $app.state.world.chunks_cached_draw_textures[0][0][0].draw

  # $app.state.world.chunks[0][0][0].blocks[0][0][0].each do |uuid, object|
  #   object.draw
  # end

  # $app.state.world.chunks[0][0][0].blocks[0][0][0].first.second.draw

  # $app.state.dirts.each do |dirt|
  #   if rand(100) <= 75
  #     dirt.x += 1
  #   end
  #
  #   if rand(100) <= 75
  #     dirt.x -= 1
  #   end
  #
  #   if rand(100) <= 75
  #     dirt.y += 1
  #   end
  #
  #   if rand(100) <= 75
  #     dirt.y -= 1
  #   end
  # end

  # $app.state.dirts[rand(1000)].tap do |dirt|
  #   if rand(100) <= 75
  #     dirt.x += 1
  #   end
  #
  #   if rand(100) <= 75
  #     dirt.x -= 1
  #   end
  #
  #   if rand(100) <= 75
  #     dirt.y += 1
  #   end
  #
  #   if rand(100) <= 75
  #     dirt.y -= 1
  #   end
  # end

  $app.state.dirts[1500].tap do |dirt|
    if rand(100) <= 75
      dirt.x += 1
    end

    if rand(100) <= 75
      dirt.x -= 1
    end

    if rand(100) <= 75
      dirt.y += 1
    end

    if rand(100) <= 75
      dirt.y -= 1
    end
  end

  # if rand(100) <= 75
  #   $app.state.dirt.x += 1
  # end
  #
  # if rand(100) <= 75
  #   $app.state.dirt.x -= 1
  # end
  #
  # if rand(100) <= 75
  #   $app.state.dirt.y += 1
  # end
  #
  # if rand(100) <= 75
  #   $app.state.dirt.y -= 1
  # end

  $app.state.camera.x = $app.state.dirt.x
  $app.state.camera.y = $app.state.dirt.y
  $app.state.camera.z = $app.state.dirt.z

  $app.state.world.draw

  $app.state.fps.string = "FPS: #{$app.internal.fps}"
  $app.state.fps.draw

  # (object_uid, object) = $app.state.dirt.grid_block.find_nearest_grid_block_below&.objects&.first
  # puts "#{object.class}-#{object_uid}"

  # $app.state.puts.string = $app.state.dirt.grid_block.find_nearest_grid_block_below&.objects.to_s #&.map(&:casted_shadow_by).to_s # $app.state.dirt.grid_block.find_nearest_grid_block_below.to_s
  # $app.state.puts.draw

  # sleep 0.01
end
