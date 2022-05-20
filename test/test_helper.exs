# Exclude some text-related tests when developing on macOS because the typeface
# doesn't match the Linux system the test images were generated on.
# They still run in Github Actions and when developing on Linux
# Also exclude some pdf tests when running on Linux because I haven't found
# a good command line tool for comparing PDFs
case :os.type() do
  {_, :darwin} -> ExUnit.start(exclude: [macos: false])
  {:unix, _} -> ExUnit.start(exclude: [pdf: true, macos: true])
  _ -> ExUnit.start()
end
