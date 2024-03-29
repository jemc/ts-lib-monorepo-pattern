import { Foo } from "@monorepo/foo"

export class Bar {
  bar() {
    return "bar"
  }

  foo() {
    return new Foo().foo()
  }
}
