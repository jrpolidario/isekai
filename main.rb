Bundler.require(:default, :development)
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'app', '*.rb')].each { |file| require file }

Application.init!

if $app.development?
  Thread.new do
    binding.pry
  end
end

$app.state.dirts ||= []

(0...500).to_a.each do |x|
  (0...500).to_a.each do |y|
    $app.state.dirts << Image.new(
      x: x * 64,
      y: y * 64,
      width: 64,
      height: 64,
      file_path: 'images/dirt_02.png'
    )
  end
end

$app.state.dirts_cache = Image.new_from_render(width: 64 * 100, height: 64 * 100) do
  $app.state.dirts.map(&:draw)
end

$app.tick do
  $app.sdl_renderer.draw_color = [0xA0, 0xA0, 0xA0]

  # $app.state.dirts.map(&:draw)

  $app.state.dirts_cache.draw

  Text.new(string: "FPS: #{$app.internal.fps}", x: 0, y: 0, color: :green).draw

  sleep 0.01
end
