local NOTE_UP = 2 ^ (1 / 12)
local NOTE_DOWN = 2 ^ (-1 / 12)
local TAU = 2.0 * math.pi

local buffer = love.sound.newSoundData(16384,44100,16,1) -- 2048 is how many samplepoints each channel has
local qsource = love.audio.newQueueableSource(44100,16,1,2) -- 2 is how many OpenAL-internal buffers the source has

local freq = 440

function love.update(dt)
  -- in update
  if qsource:getFreeBufferCount() > 0 then
    -- generate one buffer's worth of audio data; the above line is enough for timing purposes
    local phase = 0.0
    for i = 0, buffer:getSampleCount()-1 do
      local smp = math.sin(TAU * phase)
      for c = 1, buffer:getChannelCount() do
        buffer:setSample(i, c, smp)
      end
      phase = (phase + (freq / buffer:getSampleRate())) % 1.0
    end
    -- queue it up
    qsource:queue(buffer)
  end
  qsource:play() -- keep playing so playback never stalls, even if there are underruns; no, this isn't heavy on processing.
end

function love.keypressed(key)
  if key == 'k' then
    freq = freq * NOTE_UP
  elseif key == 'j' then
    freq = freq * NOTE_DOWN
  end
end