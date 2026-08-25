local control = matches[2]

if control == "start" then
    seq.restart()
elseif control == "stop" then
    seq.stop()
elseif control == "pause" then
    seq.pause()
elseif control == "resume" then
    seq.resume()
elseif control == "skip" then
    seq.skip()
end
