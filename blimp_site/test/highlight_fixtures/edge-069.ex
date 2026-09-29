try do
 x
rescue
 e -> e
catch
  :exit, _ -> 1
end