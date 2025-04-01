function boolstr(b)
  if b then
    return "1"
  else
    return "0"
  end
end

function hexstr(n)
  return string.format("%X", n)
end

function hexstr2(n)
  if n < 16 then
    return string.format("0%X", n)
  else
    return string.format("%X", n)
  end
end