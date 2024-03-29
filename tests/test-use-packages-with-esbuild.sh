#!/usr/bin/env bash
set -eu

# Build the packages in the monorepo into tarballs.
sh -c 'cd ../../monorepo; pnpm install; pnpm run pack'

# Set up a simple project that uses typescript and esbuild.
#
# We use pnpm overrides to resolve the monorepo packages as tarballs,
# which lets the rest of the test simulate as if they came from npm.
cat <<EOF > package.json
{
  "scripts": {
    "build": "esbuild --bundle src/index.ts --outdir=dist"
  },
  "pnpm": {
    "overrides": {
      "@monorepo/foo": "$(find ../../monorepo/packages/foo/dist -name '*.tgz')",
      "@monorepo/bar": "$(find ../../monorepo/packages/bar/dist -name '*.tgz')"
    }
  }
}
EOF
cat <<'EOF' > tsconfig.json
{
  "include": ["src"],
  "compilerOptions": {
    "outDir": "./dist",
  }
}
EOF
pnpm add -D typescript esbuild --prefer-offline
pnpm add @monorepo/foo @monorepo/bar --offline

# Write some simple code leveraging the monorepo libraries.
mkdir src
cat <<'EOF' > src/index.ts
import { Foo } from "@monorepo/foo"
import { Bar } from "@monorepo/bar"

console.log(new Foo().foo())
console.log(new Bar().foo())
console.log(new Bar().bar())
EOF

# Build and run the simple code in Node.js.
pnpm run build
cat dist/index.js
node dist/index.js > out.actual.txt
cat <<'EOF' > out.expected.txt
foo
foo
bar
EOF

# Confirm that we get the expected output.
diff -u out.expected.txt out.actual.txt
