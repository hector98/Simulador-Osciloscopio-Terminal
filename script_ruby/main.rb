require 'serialport'

def SerialPortFunc
  port = "/dev/ttyUSB0"
  baud_rate = 57600
  data_bits = 8
  stop_bits = 1
  parity = SerialPort::NONE

  sp = SerialPort.new(port, baud_rate, data_bits, stop_bits, parity)
end


def OsciloscopioMonitor
  voltaje_maximo = 5.0
  voltaje_minimo = 0.0
  num_filas = 5.1

  num_columnas = 160

  screen = []
  i = 0
  while i < num_filas
    j = 0
    row = []
    while j < num_columnas
      if i >= 5.0 && i <= 5.2
        if j == 0
          row << "|||||||_"
        else
          row << "_"
        end
      else
        if j == 0
          label = (voltaje_maximo - i).round(1)
          row.push label < 0.0  ? "#{label}_||-" : " #{label}_||-"
        else
          row << "|"
        end
      end
      j += 1
    end
    i += 0.1
    screen << row
  end


=begin
  screen.each do |row|
    print row.join("")
    print "\n"
  end
=end


  return screen
end


def main
  sp = SerialPortFunc()
  monitor = OsciloscopioMonitor()
  monitor_copy = monitor.map(&:dup)

  time = 1

  loop do
    data = sp.gets

    if data != "\n"
      signal, filter = data.split(":")
      volt_signal = ((signal.to_i * 5.0) / 1023.0).round(1)
      volt_filter = ((filter.to_i * 5.0) / 1023.0).round(1)

      if volt_signal == volt_filter
        monitor[monitor.length - 2 - volt_signal * 10][time] = "\e[31;47m*\e[0m"
      else
        monitor[monitor.length - 2 - volt_signal * 10][time] = "\e[30;41m*\e[0m"
        monitor[monitor.length - 2 - volt_filter * 10][time] = "\e[30;42m*\e[0m"
      end

      monitor.each do |row|
        print row.join("")
        print "\n"
      end

      time += 1

      if time == 160
        monitor = monitor_copy.map(&:dup)
        time = 1
      end
    end

    sleep 0.005
      system("clear")
  end
end


main()
#OsciloscopioMonitor()
