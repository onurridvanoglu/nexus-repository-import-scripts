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

## Usage

### Maven Import
Navigate to the root directory containing your artifacts and run:
```bash
./mavenimport.sh -u admin -p admin123 -r http://localhost:8084/repository/maven-releases/
```
Parameters:
- `-u`: Username (default: admin)
- `-p`: Password (default: admin123)
- `-r`: Repository URL (modify according to your setup)

### NuGet Import
Navigate to the directory containing your NuGet packages and run:
```bash
./nugetimport.sh -k APIKEYFROMNEXUS -r http://localhost:8084/repository/nuget-hosted/
```
Parameters:
- `-k`: API key from Nexus Repository (required)
- `-r`: Repository URL (modify according to your setup)

### npm Import
First, login to your npm registry:
```bash
npm login --registry http://localhost:8084/repository/npm-internal/
```

Then navigate to your npm packages directory and run:
```bash
./npmimport.sh -r http://localhost:8084/repository/npm-internal/
```
Parameters:
- `-r`: Repository URL (modify according to your setup)

Note: Some packages might fail due to extra build steps. You'll need to investigate and fix those cases individually.

### Repository Comparison Tool

#### Requirements
- Python 3.x
- requests library
```bash
pip install requests
```

#### Setup and Usage
1. Update the Nexus configurations in `compare_nexus_repos.py` with your URLs and credentials
2. Run the comparison:
```bash
python compare_nexus_repos.py
```

The script will generate a JSON file containing:
- Repositories only in old Nexus
- Repositories only in new Nexus
- Repositories that exist in both

Note: The comparison results file is gitignored to prevent repository information leakage.

## Important Notes
- Ensure your Nexus instances are reachable
- Verify your credentials are correct
- Don't commit sensitive information to git
- The comparison results file is excluded from git to protect your repository information

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