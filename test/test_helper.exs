ExUnit.start()

# Load test support modules
Code.compile_file("support/test_controller.ex", __DIR__)
Code.require_file("support/router.ex", __DIR__)
