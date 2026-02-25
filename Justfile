mix-test dir:
    mix cmd --cd {{dir}} mix test --color

[parallel]
test: (mix-test "hopper") (mix-test "hopper_kino")
