# Working method

## Before building

- Interview before building: for any non-trivial feature or
  design decision, ask me clarifying questions first rather than
  building on assumptions. Say up front how much process the
  request needs (a feasibility spike, a bounded change to code
  that already exists, or an architectural change) so I can
  override the call.
- Present the intended design and get my approval before writing
  code for anything non-trivial. For a bounded change that is a
  few sentences in chat; for an architectural one it is a written
  spec. A one-line fix with an obvious shape needs no ceremony.
- For non-trivial work, write the plan down before touching code:
  the files each task creates or changes, its test, and how it is
  verified, sized so every task ends at an independently testable
  deliverable. Then execute it in checkpoints, one verified
  commit per task, and stop to ask when a step is blocked or an
  instruction is unclear rather than guessing.
- Research conventions before building standard infrastructure:
  when setting up CI pipelines, packaging, release flows and the
  like, first study how flagship projects in that ecosystem
  structure theirs and follow those conventions rather than
  inventing a shape.
- Look it up, don't guess: verify claims against documentation or
  real behaviour before asserting them, and say clearly when
  something is unverified.
- Ask every question with the AskUserQuestion tool, never as
  plain prose, including open-ended ones: offer best-guess
  options (with a recommended first option where you have a view)
  and rely on the built-in Other field for free text.

## While working

- Refactor in green checkpoints: tag or note a known-good restore
  point first, then one verified commit per slice (build, tests
  and a visual check between each).
- Where a project has a test framework, new behaviour lands with
  a test, and the test comes first: watch it fail for the right
  reason, then write the smallest code that makes it pass, then
  clean up. A test you never saw fail proves nothing. Throwaway
  spikes, generated code and pure config are the exceptions, and
  they are worth asking about rather than assuming.
- Tests never touch the real system: gate every side-effecting
  call (a system opener like `open`/`xdg-open`, desktop
  notifications, sound or speech, network requests, spawned
  subprocesses) to a no-op under test, so the suite never pops a
  window, plays a sound, hits the network or launches a process
  on the machine. A test that exercises such a path asserts the
  decision, not the effect.
- Scripts fail fast and stay re-runnable; see `rules/shell.md`.
- Never leave a long-running process silent: report what is
  running and where its output goes, then check on it at least
  every two minutes (progress lines, log growth, process still
  alive) instead of only waiting for it to finish. A hung process
  must be noticed, not discovered.

## Verifying

- Evidence before claims: never call work done, fixed, passing or
  ready without having just run the command that proves it and
  read the whole output, exit code included. "Should work" is not
  a result. Report the actual state, with the output, including
  when it is a failure.
- Verify visually: check UI and document work by rendering the
  result (screenshots, rasterised PDFs), never by reading the
  code alone.
- A subagent reporting success is not evidence: read the diff and
  run the suite yourself before repeating its claim.

## Debugging

- Find the root cause before fixing anything: read the error and
  the stack trace in full, reproduce the failure reliably, check
  what changed recently, and trace the bad value back to where it
  originates. Fix it there, not where it surfaced.
- Change one thing at a time against a stated hypothesis. No
  shotgun fixes, no bundled "while I'm here" edits, and no
  raising a timeout in place of understanding the race.
- Where a test framework exists, reproduce the bug as a failing
  test before the fix, so the fix is proved and stays proved.
- After three failed fixes, stop and question the architecture
  with me instead of attempting a fourth.

## Parallel work

- Parallelise with subagents: fan independent slices of work out
  to concurrent subagents (worktree isolation when they mutate
  files). Dispatch them in a single message so they run at once,
  give each one a narrow scope, the context it needs and the
  output expected, and keep related work in one agent rather than
  splitting it.
- Never leave working state inside a repository: git worktrees
  belong under `$XDG_STATE_HOME/<project>-worktrees/`, created
  with `git worktree add` and entered by path, never in a
  `.claude/` directory inside the checkout. Remove each one the
  moment its work is integrated rather than letting them
  accumulate, since every worktree is a full checkout.
- Integrate parallel worktree agents by cherry-picking or
  rebasing their commits onto current master, never by merging
  the agent's branch wholesale: an agent branched from a base
  that master has since moved past will revert the newer work if
  merged. Commit anything an agent left uncommitted in its
  worktree first, then replay it onto the current tip and resolve
  conflicts there.
- Never sit idle while background tasks or subagents run, and
  never end a turn on "waiting for X". Before any pause,
  enumerate what does not conflict with work in flight (the next
  milestone item, tests, docs, tooling, review prep) and start
  it; treat "I'm blocked" as a claim requiring proof, since it
  has been wrong every time so far. A turn may end only on
  genuine user input being required, or when every remaining task
  would touch files an active agent owns.

## Finishing

- Before finishing a branch, dispatch a reviewer subagent over
  the diff, handing it the requirements and the base and head
  commits rather than the session history. Fix what it finds, or
  push back with technical reasoning where it is wrong.
- Finish on a green suite, then give me the integration decision
  (merge locally, push and open a pull request, or leave the
  branch as it is) instead of choosing it yourself.
