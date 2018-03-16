def commonSequence(base, sequence)
  if base != nil && sequence != nil
    if base.length < sequence.length
      return commonSequence(base, sequence[0..base.length-1])
    end

    $i = 0
    $match = nil
    $offset = base.length
    while $i < (base.length - sequence.length + 1)  do
      if base[$i..$i+sequence.length-1] == sequence
        # print base[$i..$i+sequence.length-1] + "\n"
        $match = base[$i..$i+sequence.length-1]
        return {"match" => true, "sequence" => sequence, "offset" => $offset}
      end
      $offset -= 1
      $i += 1
    end

    if sequence.length == 1
     return {"match" => false}
    end
    return commonSequence(base, sequence[0..sequence.length-2])

  end

  return {"match" => false}
end

def addZeros(bits, num_of_bits, front)
  $i = 0
  $new_bits = bits
  while $i < num_of_bits.to_i - bits.length
    if front
      $new_bits = "0" + $new_bits.to_s
    else
      $new_bits = $new_bits.to_s + "0"
    end
    $i += 1
  end

  return $new_bits
end

def encodeLZ77(bits)
  $search_buffer_size = 7
  $num_of_bits_buffer = $search_buffer_size.to_s(2).length
  $completion_count = 0

  $search_buffer = bits[0]
  $look_ahead_buffer = bits[1..-1]
  $tokens = addZeros(bits[0].ord.to_s(2), 8, true)
  $i = 0
  while $i < bits.length
    $completion_count += 1
    if $look_ahead_buffer == nil
      break
    end

    $token = commonSequence($search_buffer.to_s, $look_ahead_buffer.to_s)
    $symbol = nil
    if $look_ahead_buffer != nil
      $symbol = $look_ahead_buffer[0].to_s
    end
    $offset = 0
    $match_length = 0
    if $token["match"]
      $offset =  $token["offset"]
      $match_length = $token["sequence"].length
      $symbol = $look_ahead_buffer[$token["sequence"].length]

      $search_buffer += $token["sequence"]
      $look_ahead_buffer = $look_ahead_buffer[$token["sequence"].length..-1]
      $i += $token["sequence"].length
    end

    if $symbol != nil
      if $offset == 0
        $tokens += addZeros($symbol.ord.to_s(2), 8, true)
        # print addZeros($symbol.ord.to_s(2), 8, true) + "\n"
      else
        # print $offset.to_s + ' ' + $match_length.to_s + ' ' + $symbol + "\n"
        $tokens += "1" + addZeros($offset.to_i.to_s(2), $num_of_bits_buffer, true) + addZeros($match_length.to_i.to_s(2), $num_of_bits_buffer, true)
        $tokens += addZeros($symbol.ord.to_s(2), 7, true)
        # print  "1" + addZeros($offset.to_i.to_s(2), $num_of_bits_buffer, true) + addZeros($match_length.to_i.to_s(2), $num_of_bits_buffer, true) + addZeros($symbol.ord.to_s(2), 8, true) + "\n"
      end
    end

    $look_ahead_buffer = $look_ahead_buffer[1..-1]
    $search_buffer += $symbol.to_s

    if $search_buffer.length > $search_buffer_size
      $search_buffer = $search_buffer[$search_buffer.length-$search_buffer_size..-1]
    end
    $i += 1
  end


  return $tokens
end

def writeBitsToFile(bits, filename)
  $bytes = bits.scan(/.{8}/)
  # print bits
  $bytes.push(addZeros(bits[bits.length-(bits.length%8)..-1], 8, false))
  File.open(filename, 'wb' ) do |output|
    output.write [$bytes.join].pack("B*")
  end
end

$i = 0
$compressed_bits = nil
ARGV.each do|a|
  if ($i == 0)
    # print "Compressing File: " + "#{a}" + "\n"
    $compressed_bits = encodeLZ77(File.read("#{a}"))
  end
  $i += 1
end

if $compressed_bits == nil
  abort("Error: Missing Argument")
end
writeBitsToFile($compressed_bits, "compressed.txt")
