defmodule PacketParser do
  def hex_to_bin("0"), do: "0000"
  def hex_to_bin("1"), do: "0001"
  def hex_to_bin("2"), do: "0010"
  def hex_to_bin("3"), do: "0011"
  def hex_to_bin("4"), do: "0100"
  def hex_to_bin("5"), do: "0101"
  def hex_to_bin("6"), do: "0110"
  def hex_to_bin("7"), do: "0111"
  def hex_to_bin("8"), do: "1000"
  def hex_to_bin("9"), do: "1001"
  def hex_to_bin("A"), do: "1010"
  def hex_to_bin("B"), do: "1011"
  def hex_to_bin("C"), do: "1100"
  def hex_to_bin("D"), do: "1101"
  def hex_to_bin("E"), do: "1110"
  def hex_to_bin("F"), do: "1111"
  def hex_to_bin(_), do: ""

  def parse_packet(bin) do
    version = binary_part(bin, 0, 3) |> String.to_integer(2)
    type_id = binary_part(bin, 3, 3) |> String.to_integer(2)
    rest = binary_part(bin, 6, byte_size(bin) - 6)

    {args, rest} = parse_type(type_id, rest)

    {[version, type_id, args], rest}
  end

  # literal value
  defp parse_type(4, bin) do
    {bin_value, rest} = parse_literal(bin)

    {String.to_integer(bin_value, 2), rest}
  end

  # operator
  defp parse_type(_, bin) do
    parse_operator(bin)
  end

  # 1 means not last block, keep reading
  defp parse_literal(bin) when binary_part(bin, 0, 1) == "1" do
    value_part = binary_part(bin, 1, 4)
    rest = binary_part(bin, 5, byte_size(bin) - 5)

    {value_rest, rest} = parse_literal(rest)

    {value_part <> value_rest, rest}
  end

  # 0 means last block, stop reading
  defp parse_literal(bin) when binary_part(bin, 0, 1) == "0" do
    value_part = binary_part(bin, 1, 4)
    rest = binary_part(bin, 5, byte_size(bin) - 5)

    {value_part, rest}
  end

  # args come in number of subpackets
  defp parse_operator(bin) when binary_part(bin, 0, 1) == "1" do
    number_of_subpackets = binary_part(bin, 1, 11) |> String.to_integer(2)
    rest = binary_part(bin, 12, byte_size(bin) - 12)

    {reversed_sub_packets, rest} =
      Enum.reduce(1..number_of_subpackets, {[], rest}, fn _, {sub_packets, bin} ->
        {args, rest} = parse_packet(bin)

        {[args | sub_packets], rest}
      end)

    {Enum.reverse(reversed_sub_packets), rest}
  end

  # args come in length of subpackets
  defp parse_operator(bin) when binary_part(bin, 0, 1) == "0" do
    length_in_bits = binary_part(bin, 1, 15) |> String.to_integer(2)
    sub_packets_bin = binary_part(bin, 16, length_in_bits)

    offset = 16 + length_in_bits
    rest = binary_part(bin, offset, byte_size(bin) - offset)

    args = parse_sized_sub_packets(sub_packets_bin)

    {args, rest}
  end

  defp parse_sized_sub_packets(""), do: []

  defp parse_sized_sub_packets(bin) do
    {args, rest} = parse_packet(bin)

    [args | parse_sized_sub_packets(rest)]
  end
end

defmodule PacketUtils do
  def version_sum([version, _, args]) when is_list(args) do
    version +
      (Stream.map(args, &version_sum(&1))
       |> Enum.sum())
  end

  def version_sum([version, _, args]) when is_integer(args), do: version
end

{packet, _} =
  File.open!("input.txt")
  |> IO.stream(1)
  |> Stream.map(&PacketParser.hex_to_bin/1)
  |> Enum.join()
  |> PacketParser.parse_packet()

PacketUtils.version_sum(packet)
|> IO.inspect()
