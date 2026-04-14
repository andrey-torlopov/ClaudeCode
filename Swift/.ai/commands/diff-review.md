Conduct a code review of current changes in the git repository in the $ARGUMENTS folder and write the result to the .md file $ARGUMENTS

Steps:
1. Run `git status -s` to see a list of changed files
2. Run `git diff` to view unstaged changes
3. Run `git diff --cached` to view staged changes
4. Read each modified file in its entirety for full context

Analyze the changes and give a review based on the following criteria:
- Code correctness and logical errors
- Retain cycles and memory leaks
- Presence of potential crashes
- Thread safety (Sendable, actors, @MainActor, @unchecked Sendable)
- Compliance with Swift API Design Guidelines
- Error handling
- Event logging via Logger rather than print()


Response format:
- Answer and reasoning in Russian
- Brief description of what has been changed
- List of comments indicating file and line
- First we indicate super-critical comments and MR blockers, then in descending order
- Briefly indicate what can be improved in the future and what to watch
- If everything is fine, write that there are no comments
