# Exclude some text-related tests when developing on macOS because the typeface
# doesn't match the Linux system the test images were generated on.
# They still run in Github Actions and when developing on Linux
case :os.type() do
  {_, :darwin} -> ExUnit.start(exclude: [macos: false])
  _ -> ExUnit.start()
end
