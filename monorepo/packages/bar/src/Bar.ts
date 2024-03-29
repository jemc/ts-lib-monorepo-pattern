import { Foo } from "@monorepo/foo"
import { WORKSPACE_MANIFEST_FILENAME as PNPM_WORKSPACE_FILENAME } from "@pnpm/constants" // we include a 3rd-part dependency to verify that case

export class Bar {
  bar() {
    return "bar"
  }

  foo() {
    return new Foo().foo()
  }

  pnpmWorkspaceFilename() {
    return PNPM_WORKSPACE_FILENAME
  }
}
