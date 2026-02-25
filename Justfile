mix-test dir:
    mix cmd --cd {{dir}} mix test --color

mix-format dir:
    mix cmd --cd {{dir}} mix format

[parallel]
test: (mix-test "hopper") (mix-test "hopper_kino")

format: (mix-format "hopper") (mix-format "hopper_kino")
