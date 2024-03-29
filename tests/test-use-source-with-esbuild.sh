#!/usr/bin/env bash
set -eu

# To simulate a project using the monorepo as a git submodule, we copy the code.
cp -r ../../monorepo .

# Set up a simple project that uses typescript and esbuild.
cat <<EOF > package.json
{
  "scripts": {
    "build": "esbuild --bundle src/index.ts --outdir=dist"
  }
}
EOF
cat <<EOF > tsconfig.json
{
  "include": ["src"],
  "compilerOptions": {
    "composite": true,
    "outDir": "./dist",
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
pnpm add -D typescript esbuild

# Write some simple code leveraging the monorepo libraries.
mkdir src
cat <<EOF > src/index.ts
import { Foo } from '@monorepo/foo'
import { Bar } from '@monorepo/bar'

console.log(new Foo().foo())
console.log(new Bar().foo())
console.log(new Bar().bar())
EOF

# Build and run the simple code in Node.js.
pnpm run build
cat dist/index.js
node dist/index.js > out.actual.txt
cat <<EOF > out.expected.txt
foo
foo
bar
EOF

# Confirm that we get the expected output.
diff -u out.expected.txt out.actual.txt
