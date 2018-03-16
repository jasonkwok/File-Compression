def decodeLZ77(bits)
  $search_buffer_size = 7
  bits = bits.scan(/.{1}/)
  $x = bits
  $new_bits = ""
  while $x.length > 7
    if $x[0].to_i == 0
      $char = $x.shift(8)
      $new_bits += $char.join.to_i(2).to_s(10).to_i.chr
    else
      $token = $x.shift(1 + 2 * $search_buffer_size.to_s(2).length + 7)
      $middle_index = $search_buffer_size.to_s(2).length
      $offset = $token[1..$middle_index].join.to_i(2).to_s(10)
      $length = $token[$middle_index+1..2*$middle_index].join.to_i(2).to_s(10)
      $symbol = $token[2*$middle_index+1..2*$middle_index+8].join.to_i(2).to_s(10).to_i.chr

      $window_start = 0
      if $new_bits.length > $search_buffer_size
        $window_start = $new_bits.length - $search_buffer_size
      end
      $new_bits += getEncodedString($new_bits[$window_start..-1], $offset.to_i, $length.to_i) + $symbol;
    end
  end

  return $new_bits
end

def getEncodedString(window, offset, length)
  $index = window.length - offset
  return window[$index,length]
end

def writeTextToFile(chars, filename)
  File.open(filename, 'w') { |file| file.write(chars) }
end

# puts File.read("test.txt").length
# print commonSequence(bits,"01001")
# print bits
# print "\n"

$i = 0
$decompressed_chars = nil
ARGV.each do|a|
  if ($i == 0)
    print "Decompressing File: " + "#{a}" + "\n"
    s = File.binread("#{a}")
    bits = s.unpack("B*")[0]
    $decompressed_chars = decodeLZ77(bits)
  end
  $i += 1
end

if $decompressed_chars == nil
  abort("Error: Missing Argument")
end
writeTextToFile($decompressed_chars, "decompressed.txt")
