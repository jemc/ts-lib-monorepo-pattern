#!/usr/bin/env bash
set -eu

# Build the packages in the monorepo into tarballs.
sh -c 'cd ../../monorepo; pnpm install; pnpm run pack'

# Set up a simple project that uses typescript and jest.
#
# We use pnpm overrides to resolve the monorepo packages as tarballs,
# which lets the rest of the test simulate as if they came from npm.
cat <<EOF > package.json
{
  "scripts": {
    "test": "jest"
  },
  "pnpm": {
    "overrides": {
      "@monorepo/foo": "$(find ../../monorepo/packages/foo/dist -name '*.tgz')",
      "@monorepo/bar": "$(find ../../monorepo/packages/bar/dist -name '*.tgz')"
    }
  },
  "jest": {
    "preset": "ts-jest",
    "testEnvironment": "node"
  }
}
EOF
pnpm add -D typescript ts-jest jest @jest/globals --prefer-offline
pnpm add @monorepo/foo @monorepo/bar --offline

# Write some simple code leveraging the monorepo libraries.
mkdir src
cat <<'EOF' > src/index.ts
import { Foo } from "@monorepo/foo"
import { Bar } from "@monorepo/bar"

export class Example {
  private _foo = new Foo()
  private _bar = new Bar()

  foofoo() {
    return this._foo.foo()
  }

  barfoo() {
    return this._bar.foo()
  }

  barbar() {
    return this._bar.bar()
  }

  pnpmWorkspaceFilename() {
    return this._bar.pnpmWorkspaceFilename()
  }
}
EOF

# Run a simple test in jest.
mkdir spec
cat <<'EOF' > spec/index.spec.ts
import { describe, expect, test } from "@jest/globals"
import { Example } from "../src"

describe("Example", () => {
  test("exposes values from the libraries", () => {
    const example = new Example()
    expect(example.foofoo()).toBe("foo")
    expect(example.barfoo()).toBe("foo")
    expect(example.barbar()).toBe("bar")
    expect(example.pnpmWorkspaceFilename()).toBe("pnpm-workspace.yaml")
  })
})
EOF
pnpm run test
