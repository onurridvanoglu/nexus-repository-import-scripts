import requests
from urllib3.exceptions import InsecureRequestWarning
from typing import List, Dict
from dataclasses import dataclass
from requests.auth import HTTPBasicAuth
import json

# Disable SSL warning for self-signed certificates
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

@dataclass
class NexusConfig:
    url: str
    username: str
    password: str
    version: int  # 2 or 3

class NexusRepositoryComparer:
    def __init__(self, old_nexus: NexusConfig, new_nexus: NexusConfig):
        self.old_nexus = old_nexus
        self.new_nexus = new_nexus

    def get_repositories_v2(self, nexus_config: NexusConfig) -> List[Dict]:
        """Fetch repositories from Nexus 2.x"""
        url = f"{nexus_config.url}/service/local/repositories"
        try:
            response = requests.get(
                url,
                auth=HTTPBasicAuth(nexus_config.username, nexus_config.password),
                verify=False,
                headers={
                    'accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            )
            response.raise_for_status()
            return response.json()['data']
        except requests.exceptions.RequestException as e:
            print(f"Error accessing Nexus 2 repositories: {str(e)}")
            raise

    def get_repositories_v3(self, nexus_config: NexusConfig) -> List[Dict]:
        """Fetch repositories from Nexus 3.x"""
        url = f"{nexus_config.url}/service/rest/v1/repositories"
        try:
            response = requests.get(
                url,
                auth=HTTPBasicAuth(nexus_config.username, nexus_config.password),
                verify=False
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error accessing Nexus 3 repositories: {str(e)}")
            raise

    def get_repositories(self, nexus_config: NexusConfig) -> List[str]:
        """Get repository names based on Nexus version"""
        if nexus_config.version == 2:
            repos = self.get_repositories_v2(nexus_config)
            return [repo['id'] for repo in repos]
        else:
            repos = self.get_repositories_v3(nexus_config)
            return [repo['name'] for repo in repos]

    def find_unique_repositories(self) -> Dict[str, List[str]]:
        """Find repositories that exist only in old or new Nexus"""
        try:
            old_repos = set(self.get_repositories(self.old_nexus))
            new_repos = set(self.get_repositories(self.new_nexus))

            only_in_old = old_repos - new_repos
            only_in_new = new_repos - old_repos

            return {
                'only_in_old_nexus': sorted(list(only_in_old)),
                'only_in_new_nexus': sorted(list(only_in_new)),
                'common_repositories': sorted(list(old_repos & new_repos))
            }
        except requests.exceptions.RequestException as e:
            print(f"Error comparing Nexus repositories: {str(e)}")
            raise

def main():
    # Configure your Nexus instances
    old_nexus = NexusConfig(
        url="http://nexus.logo.com.tr:8081/nexus",
        username="username",
        password="password",
        version=2
    )

    new_nexus = NexusConfig(
        url="https://sonarnexus.logo.com.tr:8443",
        username="username",
        password="password",
        version=3
    )

    comparer = NexusRepositoryComparer(old_nexus, new_nexus)
    
    try:
        # Get repository comparison
        results = comparer.find_unique_repositories()

        # Save results to a JSON file
        with open('repository_comparison.json', 'w') as f:
            json.dump(results, f, indent=2)

        # Print summary
        print("\n=== Repository Comparison Summary ===")
        print(f"Repositories only in old Nexus: {len(results['only_in_old_nexus'])}")
        print(f"Repositories only in new Nexus: {len(results['only_in_new_nexus'])}")
        print(f"Common repositories: {len(results['common_repositories'])}")

    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    main()