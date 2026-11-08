# Build and release evidence

## Experimental Windows export
A GitHub Actions job should install the pinned Godot editor and matching export templates, import the project and export Windows x86_64 to a downloadable CI artifact.

## Validation levels
1. Export command exits successfully and produces nonempty executable.
2. Artifact can be downloaded and inspected.
3. Executable launches on a real Windows machine (not proved by Linux export).
4. Automated interaction, persistence and rendered visuals pass.
5. Human-reviewed graphical quality meets the approved style.

Do not call the result a release until all applicable gates pass. Export templates and third-party Actions must be pinned and checked for licensing and integrity before a production release pipeline.
