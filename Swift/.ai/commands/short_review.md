Conduct a short code review of current changes in the git repository in the $ARGUMENTS folder

Steps:
1. Run `git status -s` to see a list of changed files
2. Run `git diff` to view unstaged changes
3. Run `git diff --cached` to view staged changes
4. Read each modified file in its entirety for full context

Analyze the changes and give a brief review of only critical bugs:
- Code correctness and logical errors
- Retain cycles and memory leaks
- Thread safety (Sendable, actors, @MainActor, @unchecked Sendable)
- Compliance with Swift API Design Guidelines
- Error handling
- Event logging via Logger.app.info/debug/warning
- Potential crashes

Response format:
- A brief list of things that urgently need to be corrected and cannot be changed
- List of comments indicating file and line
- Suggestions for improvement
- If everything is fine, write that there are no comments
