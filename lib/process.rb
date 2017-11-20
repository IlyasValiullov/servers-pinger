out = IO.popen('ping -w 5 google.ru')
Process.wait(out.pid)
puts out.readlines
