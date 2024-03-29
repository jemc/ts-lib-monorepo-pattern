#!/usr/bin/env bash
set -eu

# To simulate a project using the monorepo as a git submodule, we copy the code.
cp -r ../../monorepo .

# Set up a simple project that uses typescript and jest.
cat <<'EOF' > package.json
{
  "scripts": {
    "test": "jest"
  },
  "jest": {
    "preset": "ts-jest",
    "testEnvironment": "node",
    "moduleNameMapper": {
      "@monorepo/(.+)": "<rootDir>/monorepo/packages/$1/src"
    }
  }
}
EOF
cat <<'EOF' > tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "paths": {
      "@monorepo/*": ["./monorepo/packages/*/src"]
    }
  },
  "references": [
    { "path": "./monorepo/packages/foo" },
    { "path": "./monorepo/packages/bar" }
  ]
}
EOF
pnpm add -D typescript ts-jest jest @jest/globals --prefer-offline

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
  })
})
EOF
pnpm run test
