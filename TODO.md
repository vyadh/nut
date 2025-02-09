# Ideas

A random collection of stuff that may or may not be useful to consider.

- Overlays
  - Add each dependency as an overlay
  - Use the repo name as the overlay name
  - When using an overlay, use zero to bring it back to the front
  - Allow specifying an alternative name in dependencies to resolve clashes
  - Always create with prefix, at least for now
  - Reload overlay if it was already in use
- Lock file
  - We currently add revision to the project file, as it seems little point without below features. This should move to a lock file.
  - Transitive dependencies
- Versions
  - Version bounds, made concrete in the lock file
  - On resolving package versions, use MVS, minimum version selection
  - Monorepos with tag-based versioning
- Licenses
  - Check spdx and warn on bad license data
  - Use noassertion for invalid/missing licenses
- Trust
  - Identity checks
  - How to deny-list known bad packages? A use for an index? Meaning deny-list-only one
- UX
  - Auto-completion to help resolve URIs from already-ingested packages?
  - If using name shortcuts, could have local-only aliasing to resolve conflicts
  - Test HTTP redirects for package URIs possible
