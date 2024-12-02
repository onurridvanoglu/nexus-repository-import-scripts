# Nexus Repository Import Scripts
## Wut?
These are bare bones bash scripts to import a Nexus 2 Maven, NuGet or npm repository (and likely other file system based repos)
into Nexus Repository 3, plus some Python scripts to compare repositories between Nexus 2 and 3.
### Wut does it do?
* Imports artifacts into a Nexus Repository 3 Maven2, NuGet or npm hosted repo
* Compares repositories between Nexus 2 and Nexus 3 instances
* Shows you what repos exist where
### Wut does it not do?
Literally anything else. You want security? Better set it up yourself.
## How do I use it?
### Import Scripts
* Maven
  * cd rootdirectorywithallyourartifacts
  * ./mavenimport.sh -u admin -p admin123 -r http://localhost:8084/repository/maven-releases/
  * Watch a bunch of verbose output from curl
  * If need be, change -u to user, -p to password, and -r (I bet you'll have to change this) to the repo you want to upload in to
* NuGet
  * cd rootdirectorywithallyournugetpackages
  * ./nugetimport.sh -k APIKEYFROMNEXUS - r http://localhost:8084/repository/nuget-hosted/
  * Watch the money roll in and the haters start askin
  * You'll need to obtain your APIKEY for Nexus Repository, and obviously set -r to the repo path you want to use
* npm
  * npm login --registry http://localhost:8084/repository/npm-internal/
  * cd rootdirectorythatcontainsallnpmmadness
  * ./npmimport.sh -r http://localhost:8084/repository/npm-internal/
  * Watch a bunch of stuff prolly fail because it has extra build steps, figure those out and then remediate if you really care
  * Set -r and --registry to the NPM hosted repo you plan to use

### Repository Comparison Script
* Python script that tells you what repos you got where
* Requirements:
  * Python 3.x
  * requests library (`pip install requests`)
* Usage:
  * Update the Nexus configs in `compare_nexus_repos.py` with your URLs and creds
  * Run it: `python compare_nexus_repos.py`
  * Get a nice JSON file showing:
    * Repos only in old Nexus
    * Repos only in new Nexus
    * Repos that exist in both
  * The comparison results file is gitignored cuz nobody wants your repo list in their repo
## Like it?
Great, buy me a beer.

## Notes
* Make sure your Nexus instances are actually reachable
* Make sure your creds actually work
* Don't commit sensitive stuff to git (duh)
