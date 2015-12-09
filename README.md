# node-sourcerepo

A NodeJS client for the SourceRepo "API"

### Example usage

```coffee
#!/usr/bin/iced

Project    = require "./node-sourcerepo/project"
ProjectCLI = require "./node-sourcerepo/project-cli"
{log} = console

repo = process.argv[2]
log "creating repo #{repo}"

project = new Project
  account:  "your-account/subdomain-name"
  username: "your-username"
  users:
    "your-sourcerepo-git-username": <num> # your sourcerepo git username id
  log: log

projectCLI = new ProjectCLI project

await projectCLI.login defer()
await project.create repo, "Git", projectCLI.esc defer id
await projectCLI.authorize id, defer()
log "success"
```

(C) 2015 doublerebel