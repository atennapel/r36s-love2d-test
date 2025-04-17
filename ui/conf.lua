function love.conf(t)
  t.version = "11.5"
  t.identity = "r36s-love2d-test-keytest"

  t.window.title = "R36s Love2D key test"
  t.window.width = 640
  t.window.height = 480
  t.window.borderless = false
  t.window.resizable = false
  t.window.fullscreen = false
  t.window.fullscreentype = "desktop"

  t.modules.audio = true
  t.modules.data = true
  t.modules.event = true
  t.modules.font = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = true
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = false
  t.modules.sound = true
  t.modules.system = true
  t.modules.thread = true
  t.modules.timer = true
  t.modules.touch = false
  t.modules.video = false
  t.modules.window = true
end