defmodule MiniForth do
  @moduledoc """
  synopsis:
    Prints args, possibly multiple times.
  usage:
    $ test10 {options} arg1 arg2 ...
  options:
    --verbose     Add more info.
    --count=n     Print n times.
  """

  def main([]) do
    IO.puts(@moduledoc)
  end

  def main([help_opt]) when help_opt == "-h" or help_opt == "--help" do
    IO.puts(@moduledoc)
  end

  def main(args) do
    {opts, positional_args, errors} =
      args
      |> parse_args

    case errors do
      [] ->
        process_args(opts, positional_args)

      _ ->
        IO.puts("Bad option:")
        IO.inspect(errors)
        IO.puts(@moduledoc)
    end
  end

  defp parse_args(args) do
    {opts, cmd_and_args, errors} =
      args
      |> OptionParser.parse(strict: [verbose: :boolean, count: :integer])

    {opts, cmd_and_args, errors}
  end

  defp process_args(opts, args) do
    count = Keyword.get(opts, :count, 1)

    # printfn =
    #   if not Keyword.has_key?(opts, :verbose) do
    #     fn arg -> IO.puts(arg) end
    #   else
    #     fn arg ->
    #       IO.write("Message: ")
    #       IO.puts(arg)
    #     end
    #   end

    Stream.iterate(0, &(&1 + 1))
    |> Stream.take(count)
    |> Enum.each(fn _counter ->
      Enum.with_index(args)
      |> Enum.each(fn {arg, _idx} ->
        # printfn.("#{idx}. #{arg}")

        try_to_run_sv_code(arg)
      end)
    end)
  end

  defp try_to_run_sv_code(arg) do
    code = File.read!(arg)

    raw =
      code
      |> C.parse()
      |> C.replace()
      |> Map.get(:main)

    IO.puts("Raw script: \n" <> inspect(raw) <> "\n")

    raw
    |> :interpreter.eval()
    |> print_stacks()
  end

  defp print_stacks({m, a}) do
    IO.puts("MainStack: " <> inspect(m))
    IO.puts("AltStack:  " <> inspect(a))
  end
end

# MiniForth.main(System.argv())