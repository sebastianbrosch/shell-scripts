# SuiteCRM

## Update SuiteCRM in a Docker Container (`update.sh`)
This script was implemented to update SuiteCRM in a Docker Container (especially for [bitnami/suitecrm](https://hub.docker.com/r/bitnami/suitecrm/)).

**Note:** _Create a backup of your SuiteCRM installation before updating SuiteCRM._

### How to run this script?

#### On a Docker host managing the SuiteCRM container

 1. Download the script: `wget -q -O update.sh https://raw.githubusercontent.com/sebastianbrosch/shell-scripts/main/suitecrm/update.sh`
 2. Get the ID or name of your SuiteCRM container: `docker ps --format="{{.ID}} {{.Names}}"`
 3. Run the script to update SuiteCRM:
    - update to specific version: `bash update.sh -v 8.4.0 -c <container>`
    - update to latest version: `bash update.sh -V -c <container>`

#### On a Docker Container containing the SuiteCRM installation

 1. Get the ID or name of your SuiteCRM container: `docker ps --format="{{.ID}} {{.Names}}"`
 2. Switch into the terminal of the container: `docker exec -it <container> bash`
 3. Download the script: `wget -q -O update.sh https://raw.githubusercontent.com/sebastianbrosch/shell-scripts/main/suitecrm/update.sh`
 4. Run the script to update SuiteCRM:
    - update to specific version: `bash update.sh -v 8.4.0`
    - update to latest version: `bash update.sh -V`

#### After using this script you should check your installation

 1. Repair your installation (Admin &rarr; Admin Tools &rarr; Repair &rarr; Quick Repair and Rebuild)
 2. Check your multi-language settings. I recommend to re-import the [translation files](https://crowdin.com/project/suitecrmtranslations).
 3. Check your customizations in SuiteCRM.

**You can update your SuiteCRM 8.2.X, 8.3.X or 8.4.X installation to one of these versions:**

 - 8.2: [8.2.0](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.0), [8.2.1](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.1), [8.2.2](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.2), [8.2.3](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.3), [8.2.4](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.4)
 - 8.3: [8.3.0](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.3.0), [8.3.1](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.3.1)
 - 8.4: [8.4.0](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.4.0)

_The script should be checked before use. The use of this script is at your own risk._