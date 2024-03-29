#!/usr/bin/env bash
set -eu

# To simulate a project using the monorepo as a git submodule, we copy the code.
cp -r ../../monorepo .

# Set up a simple project that uses typescript and vitest.
cat <<'EOF' > package.json
{
  "type": "module",
  "scripts": {
    "test": "vitest run"
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
cat <<'EOF' > vite.config.ts
import { defineConfig } from "vitest/config"
import path from "path"

export default defineConfig({
  resolve: {
    alias: [
      {
        find: /^@monorepo\/(.+)$/,
        replacement: path.resolve(__dirname, "./monorepo/packages/$1/src"),
      },
    ],
  },
});
EOF

pnpm add -D typescript vitest vite-tsconfig-paths --prefer-offline

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

# Run a simple test in vitest.
mkdir spec
cat <<'EOF' > spec/index.spec.ts
import { describe, expect, test } from "vitest"
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
