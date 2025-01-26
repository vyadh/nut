# Zero Code

There are package management and build systems that allow untrusted code execution as part of the resolution process and package installation. This is widely regarded as a security risk. It is worse than doing `curl <untrusted url> | bash` because the package being installed could be several levels down in the dependency hierarchy and the user has very little visibility of what is happening.

The other consideration is that installing and building software is done within a different security context to code running in applications. The CI/CD chain may have access to sensitive credentials for one. Another is that arbitrary code execution in the resolution process provides no opportunity to leverage code scanning tools before code is run aside from generic, and therefore limited, scanning tools that sit around a corporate proxy.
