if Mix.env() == :test do
  defmodule Mix.Tasks.Wayfinder.GenerateTests do
    @shortdoc "compiles the test workbench router to trigger TypeScript generation."
    use Mix.Task

    @moduledoc """
    Compiles the test workbench router which triggers the @after_compile callback
    that generates TypeScript routes. This tests the Phoenix router macro integration.
    """

    def run(_args) do
      # Hardcoded path to the workbench app
      workbench_path = Path.expand("workbench", File.cwd!())

      write_outdated_controller()

      Mix.shell().info("Compiling workbench router...")

      System.cmd("mix", ["clean"],
        cd: workbench_path,
        stderr_to_stdout: true
      )

      # Use mix do to run both app.start and compile in sequence
      # This ensures the OTP application is available during compilation
      {output, exit_code} =
        System.cmd("mix", ["do", "app.start,", "compile"],
          cd: workbench_path,
          stderr_to_stdout: true
        )

      # Display output of the compilation process
      # This way we can debug wayfinder issues
      if exit_code == 1 do
        Mix.raise(output)
      else
        Mix.shell().info(output)
      end
    end

    # This function writes an outdated generated JS controller file
    # to the workbench assets/js/actions folder to prove the system
    # do the cleanup before generating new files.
    defp write_outdated_controller do
      sentinel =
        Path.expand(
          "workbench/assets/js/actions/OutdatedController/index.ts",
          File.cwd!()
        )

      File.mkdir_p!(Path.dirname(sentinel))
      File.write!(sentinel, "// This file should be deleted by codegen pre-cleanup")
    end
  end
end
