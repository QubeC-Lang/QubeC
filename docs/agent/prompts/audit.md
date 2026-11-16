Run a consistency audit of the QubeC design. Treat this as a new task with the next free task ID.
1. Orient: read CLAUDE.md, docs/agent/workflow.md, and the tracker.
2. Check, changing nothing yet: that every spec rule cites a live decision; that the grammar agrees with the spec and with every example (parse them if tooling exists); that the formal rules cover every decided construct and use consistent notation; that every Provisional mark points to an open question; that glossary coverage and define-before-use hold; that the tour uses only decided features; that the links resolve; that no decisions contradict each other; and that the roadmap statuses match the task log.
3. Report the findings most severe first, with file, line, and a proposed fix. Ask about the ones needing a design choice one at a time, explaining the options first.
4. Apply the fixes I approve, log the task, ask about the commit, then stop.
