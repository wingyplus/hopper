# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Run from the `hopper/` directory:

```bash
mix test                                        # run all tests
mix test test/hopper/core/file_test.exs         # run a single test file
mix test test/hopper/core/file_test.exs:42      # run a specific test by line number
mix compile                                     # compile the project
mix run generate_pdf.exs                        # generate output.pdf (manual smoke test)
```

No linter is configured. No external dependencies.

## Architecture

This is a PDF 2.0 generation library (ISO 32000-2) in early development. The current scope is serializing the nine PDF object types and assembling them into a valid binary file structure.

### Core layer: `Hopper.Core`

**`Hopper.Core.Object`** (`hopper/lib/hopper/core/object.ex`) — A protocol with a single callback `to_iodata/1`. Every PDF object type implements this protocol and returns iodata (never a plain string). Native Elixir types `Integer`, `Float`, and `nil` (null) implement it directly. All other types use structs.

**`Hopper.Core.Objects`** (`hopper/lib/hopper/core/object.ex`, bottom half) — Factory module. Always construct objects through these factory functions rather than building structs directly:

| Factory                        | Struct                 |
| ------------------------------ | ---------------------- |
| `Objects.boolean/1`            | `%Boolean{}`           |
| `Objects.lit_string/1`         | `%LitString{}`         |
| `Objects.hex_string/1`         | `%HexString{}`         |
| `Objects.array/1`              | `%Array{}`             |
| `Objects.name/1`               | `%Name{}`              |
| `Objects.dictionary/1`         | `%Dictionary{}`        |
| `Objects.stream/2`             | `%Stream{}`            |
| `Objects.indirect_object/3`    | `%IndirectObject{}`    |
| `Objects.indirect_reference/2` | `%IndirectReference{}` |

Dictionary entries are `{binary_key, value}` pairs — the factory wraps keys into `%Name{}` automatically. Stream's `/Length` is injected automatically from `byte_size(data)`.

**`Hopper.Core.File`** (`hopper/lib/hopper/core/file.ex`) — Assembles a complete PDF binary from a list of `%IndirectObject{}` structs. `build/3` returns iodata:

```elixir
Hopper.Core.File.build(objects, root_object_number, id: {id1_bytes, id2_bytes})
```

It emits: header → body (each object serialized + `"\n"`) → xref table → trailer. Object byte offsets are tracked during serialization, so the xref table is always exact.

### Object struct locations

All struct + protocol-impl pairs live in `hopper/lib/hopper/core/objects/`. Each file defines the struct module and its `Hopper.Core.Object` implementation together (e.g. `indirect.ex` defines both `IndirectObject` and `IndirectReference`).

### Reference script

`hopper/generate_pdf.exs` is a standalone raw-string implementation that produces a valid `output.pdf`. It serves as a ground-truth reference and manual smoke test — do not remove or break it.

### Spec

`hopper/SPEC.md` documents ISO 32000-2 file structure rules (header format, xref 20-byte entry layout, required trailer keys, etc.). Consult it when implementing new file-level features.
