Rubuild::Application.init!(name: 'Isekai')

Dir[File.join(__dir__, 'helpers', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '**', 'base.rb')].each { |file| require file }

$app.state.world = Worlds::Default.new

$app.state.fps = Texts::Default.new(x: 0, y: 0, color: :green)

$app.state.dirts = []

(0...1).to_a.each do |z|
  (0...($app.window.height * 2 / Blocks::Base::SIZE)).to_a.each do |y|
    (0...($app.window.width / Blocks::Base::SIZE)).to_a.each do |x|
      $app.state.dirts << Blocks::Dirt01.new(
        world: $app.state.world,
        x: x * Blocks::Base::SIZE,
        y: y * Blocks::Base::SIZE,
        z: z * Blocks::Base::SIZE
      )
    end
  end
end

$app.state.dirts << Blocks::Dirt01.new(
  world: $app.state.world,
  x: 5 * Blocks::Base::SIZE,
  y: 5 * Blocks::Base::SIZE,
  z: -1 * Blocks::Base::SIZE
)

$app.state.dirts << Blocks::Dirt01.new(
  world: $app.state.world,
  x: 6 * Blocks::Base::SIZE,
  y: 5 * Blocks::Base::SIZE,
  z: -1 * Blocks::Base::SIZE
)

$app.state.dirts << Blocks::Dirt01.new(
  world: $app.state.world,
  x: 6 * Blocks::Base::SIZE,
  y: 6 * Blocks::Base::SIZE,
  z: -1 * Blocks::Base::SIZE
)

$app.state.dirts << Blocks::Dirt01.new(
  world: $app.state.world,
  x: 10 * Blocks::Base::SIZE,
  y: 10 * Blocks::Base::SIZE,
  z: -1 * Blocks::Base::SIZE
)

$app.state.dirts << Blocks::Dirt01.new(
  world: $app.state.world,
  x: 10 * Blocks::Base::SIZE,
  y: 10 * Blocks::Base::SIZE,
  z: -2 * Blocks::Base::SIZE
)

# $app.state.player << Blocks::Player.new(
#   world: $app.state.world,
#   x: 10 * Blocks::Base::SIZE,
#   y: 10 * Blocks::Base::SIZE,
#   z: -1 * Blocks::Base::SIZE
# )

# (0...($app.window.height * 2 / Blocks::Base::SIZE)).to_a.reverse.each do |z|
#   (0...1).to_a.each do |y|
#     (0...1).to_a.each do |x|
#       $app.state.dirts << Blocks::Dirt01.new(
#         world: $app.state.world,
#         x: x * Blocks::Base::SIZE,
#         y: y * Blocks::Base::SIZE,
#         z: z * Blocks::Base::SIZE
#       )
#     end
#   end
# end

# (0...1).to_a.reverse.each do |z|
#   (0...6).to_a.reverse.each do |y|
#     (0...6).to_a.each do |x|
#       $app.state.dirts << Blocks::Dirt01.new(
#         world: $app.state.world,
#         x: x * Blocks::Base::SIZE,
#         y: y * Blocks::Base::SIZE,
#         z: z * Blocks::Base::SIZE
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

$app.tick do
  $app.sdl_renderer.draw_color = [0xA0, 0xA0, 0xA0]

  #
  # $app.state.dirt.draw

  # $app.state.dirts.map(&:draw)

  $app.state.world.draw

  # binding.pry

  # $app.state.world.chunks_cached_draw_textures[0][0][0].draw

  # $app.state.world.chunks[0][0][0].blocks[0][0][0].each do |uuid, object|
  #   object.draw
  # end

  # $app.state.world.chunks[0][0][0].blocks[0][0][0].first.second.draw



  $app.state.fps.string = "FPS: #{$app.internal.fps}"
  $app.state.fps.draw

  # sleep 0.01
end
