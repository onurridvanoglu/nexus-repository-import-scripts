# Nexus Repository Import Scripts

## What is this?
These are bash scripts to safely import artifacts from Nexus 2 into Nexus Repository 3, plus Python scripts to compare repositories between Nexus 2 and 3. The scripts include overwrite prevention to protect existing artifacts.

### Features
* Imports artifacts into Nexus Repository 3 (Maven2, NuGet, or npm hosted repos)
* Prevents overwriting of existing artifacts
* Compares repositories between Nexus 2 and 3 instances
* Shows repository differences and artifact counts
* Provides detailed success/failure/skip reporting

### What it doesn't do
* Modify existing artifacts
* Transfer repository permissions
* Transfer repository configurations

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

The script will:
- Check if each artifact already exists
- Skip existing artifacts (preventing overwrites)
- Upload only new artifacts
- Provide a summary of uploaded, skipped, and failed artifacts

### NuGet Import
Navigate to the directory containing your NuGet packages and run:
```bash
./nugetimport.sh -k APIKEYFROMNEXUS -r http://localhost:8084/repository/nuget-hosted/
```
Parameters:
- `-k`: API key from Nexus Repository (required)
- `-r`: Repository URL (modify according to your setup)

The script will:
- Verify if each package version exists
- Skip existing packages
- Upload only new packages
- Show a summary of results

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

The script will:
- Check package versions before upload
- Skip existing versions
- Upload only new packages
- Provide detailed upload statistics

Note: Some packages might fail due to extra build steps. You'll need to investigate and fix those cases individually.

### Repository Comparison Tools

#### Requirements
- Python 3.x
- requests library
```bash
pip install requests
```

#### Repository Comparison Script
* Compares repositories between Nexus 2 and 3
* Requirements:
  * Python 3.x
  * requests library (`pip install requests`)
* Usage:
  * Update the Nexus configs in `nexus_config.json`
  * Run: `python compare_nexus_repos.py`
  * Get a JSON file showing:
    * Repos only in old Nexus
    * Repos only in new Nexus
    * Repos that exist in both

#### Artifact Comparison Script
* Compares artifacts within common repositories
* Usage:
  * Configure `nexus_config.json` with your server details
  * Run: `python compare_nexus_artifacts.py`
  * Generates detailed reports in `comparison_results/`:
    * artifact_comparison_details.json
    * artifact_comparison_summary.json

## Important Notes
* Always verify your credentials before running imports
* Make sure your Nexus instances are reachable
* The scripts include overwrite protection by default
* All comparison results are gitignored for security
* Failed uploads are logged and reported
* Skipped items (already existing) are tracked and reported

## Security Notes
* Use read-only accounts for comparison scripts
* Use minimal-privilege accounts for uploads
* Don't commit credentials to git
* The comparison results files are gitignored to prevent repository information leakage

## Like it?
Great, buy me a beer.