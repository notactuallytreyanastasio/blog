receive do
  msg -> msg
after
  100 -> :timeout
end