# TypeScript library monorepo pattern

This repository is for exploring, testing, and refining a pattern for managing a monorepo with multiple TypeScript libraries, with interdependencies between them.

Setting up such a monorepo is far more fiddly than one might hope, hence it seemed worthwhile to set up this repo dedicated to the task, separate from whatever specific projects I am working on. It's also hoped that my findings here may be useful to others who have been similarly frustrated.

# Repository Structure

This repository's top level sits at one level higher than the monorepo pattern itself, so that we can have some tests and documentation that live outside the simulated monorepo. It's a sort of "meta-repo" structure, if you will.

- `monorepo` - The monorepo pattern itself, with minimal config and two example libraries
  - `packages` - The libraries themselves
    - `foo` - A simple library with no dependencies
    - `bar` - A simple library with a dependency on `foo`
- `tests` - End-to-end tests of the monorepo setup, which simulate different ways of using it
  - `run-all-tests.sh` - A script to run all tests, in series
  - `run-test.sh` - A script to run one tests (passing the desired test script as a CLI arg)
  - `test-*.sh` - The individual test scripts which each simulate a different scenario

If you're looking to use this repository as a pattern, look in the `monorepo` directory at each file and copy the configuration settings you see. The configuration is as minimal as possible (to avoid making you copy unnecessary options), and all of the files are well-documented with comments to explain why each configuration option is needed (except for the `package.json` files, which frustratingly cannot use comments).

Then, you can also look at the `tests` directory to see what configuration may be needed at the use site to make the monorepo work as expected. The tests are designed to simulate different ways of using the monorepo, so you can see how to set it up in your own project.

If you're making modifications and running the `tests` locally, please note that each test forces everything to be in a fresh state - the script will delete all ignored and untracked files in the `monorepo` directory, and it requires any changes to that directory's tracked files to be either staged or committed, before the test runs. This is to ensure that the tests are deterministic and don't rely on any state that may have been left over from a previous test.

## Assumptions, Constraints, and Goals

- All libraries are written in TypeScript.

- The libraries can depend on each other, and on third-party libraries.

- Common concerns which cut across all libraries can be maintained in a central way in the monorepo.

- Each library can be published as a separate package to npm, with separate versioning.

- However, it is also possible to use the monorepo as a submodule in another project, so that the libraries can be developed together with projects that use them.

- When used as a monorepo (either in developing the monorepo, or as a submodule in another project), each library can use the "live" version of the code in the other libraries, rather than needing a cumbersome "publish/rebuild" of the dependencies as a separate step.

- As much as possible, the setup should be minimalistic in its dependencies and DRY in its configuration.

- It's okay to be opinionated about the tools used, as long as they are widely-used and well-supported.

- Each file should contain some documentation describing its purpose and how it fits into the overall pattern, to make it easy for people (including myself, in the future, after I forget all this arcane knowledge of the tools) to understand how it works (and maybe get an inkling of how to fix it if it breaks with new versions of the tools).
