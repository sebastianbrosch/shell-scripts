# SuiteCRM

## Update SuiteCRM in a Docker Container [`update.sh`]
This script was implemented to update SuiteCRM running in a Docker container (especially [bitnami/suitecrm](https://hub.docker.com/r/bitnami/suitecrm/)).

**Note:** _Create a backup of your SuiteCRM installation before updating SuiteCRM._

### How to run this script?

#### On a Docker host managing the SuiteCRM container:

``` shell
# download the script to the Docker host.
wget -q -O update.sh https://raw.githubusercontent.com/sebastianbrosch/shell-scripts/main/suitecrm/update.sh

# get some basic information of the containers to find the SuiteCRM container.
docker ps --format="{{.ID}} {{.Names}}"

# run the script to update your SuiteCRM container to the latest version.
# replace <container> with the ID of your SuiteCRM container.
bash update.sh -V -c <container>

# you can also update to a specific version.
bash update.sh -v 8.4.0 -c <container>
```

#### On a Docker container containing the SuiteCRM installation:

``` shell
# get some basic information of the containers to find the SuiteCRM container.
docker ps --format="{{.ID}} {{.Names}}"

# switch into the terminal of the SuiteCRM container.
# replace <container> with the ID of your SuiteCRM container.
docker exec -it <container> bash

# download the script to the SuiteCRM container.
wget -q -O update.sh https://raw.githubusercontent.com/sebastianbrosch/shell-scripts/main/suitecrm/update.sh

# run the script to update your SuiteCRM container to the latest version.
bash update.sh -V

# you can also update to a specific version.
bash update.sh -v 8.4.0
```

#### After using this script you should check your installation

 1. Repair your installation (Admin &rarr; Admin Tools &rarr; Repair &rarr; Quick Repair and Rebuild)
 2. Check your multi-language settings. I recommend to re-import the [translation files](https://crowdin.com/project/suitecrmtranslations).
 3. Check your customizations in SuiteCRM.

**You can update your SuiteCRM 8.2.X, 8.3.X or 8.4.X installation to one of these versions:**

 - 8.2: [8.2.0](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.0), [8.2.1](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.1), [8.2.2](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.2), [8.2.3](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.3), [8.2.4](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.2.4)
 - 8.3: [8.3.0](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.3.0), [8.3.1](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.3.1)
 - 8.4: [8.4.0](https://github.com/salesagility/SuiteCRM-Core/releases/tag/v8.4.0)

_The script should be checked before use. The use of this script is at your own risk._