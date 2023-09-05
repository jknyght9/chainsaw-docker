# Chainsaw to Docker

Chainsaw (WithSecureLabs) uses Sigma and custom rules to search/hunt for forensic artifacts in Windows Event Logs and more. This project dockerizes the Chainsaw project and provides a process of updating Sigma rules from various sources.

## Sigma Rules

In the arena of detection rules, we often associate **Snort/IDS rules** to network traffic and **YARA** to files on a system. [Sigma](https://github.com/SigmaHQ/sigma) is a generic signature format for Security Incident and Event Management (SIEM) systems and is typically used against system log files. While Sigma offers a set of default signatures, other Threat Intelligence platforms offer community and paid for options. This project includes the following signature sets:

- Sigma (Default)
- Valhalla Community - NextronSystem

## Getting Started

Building the image will download all the required software and install it into the container. It will also **download the latest set of signatures!** When you want to update the container, just rebuild the container.

```shell
docker build -t chainsaw-docker:latest . --no-cache
```

### Volumes

Before running the tool, we need to understand how we get data from our host system's filesystem into the container's filesystem. We do this by mapping a volume between the host and container. To accomplish this, we use the `--volume` argument in `docker run`.

```shell
# Example - volume mapping

docker run --rm -it --volume=./:/data chainsaw-docker:latest
```

This example maps the current directory on your host system to the `/data` folder on the container. Say that we have Chainsaw's example data `EVTX-ATTACK-SAMPLES` in our current directory. When we run the above command, any arguments passed to chainsaw that reference data on our host **MUST** have `/data/` in front of it, as this refers to the mapped volume in the container.

```shell
# Example with EVTX-ATTACK-SAMPLES data

docker run --rm -it --volume=./:/data chainsaw-docker:latest hunt /data/EVTX-ATTACK-SAMPLES
```

## Hunting

All sigma rule, mapping, and rules folders are internal to the container, so no volume mapping is required for these. Simply navigate to the folder containing the log files you wish to process and run the following command

```shell
# Example - hunting for bad stuff

docker run --rm -it --volume=./:/data chainsaw-docker:latest hunt /data/EVTX-ATTACK-SAMPLES -s sigma/ --mapping mappings/sigma-event-logs-all.yml -r rules/
```

## Alias

You can create an alias (depending on your terminal emulator) to streamline this process. For example, using FISH, we can create the following function to start a hunt on a specific folder.

```shell
function chainsaw-hunt
    docker run --rm -it --volume=./:/data chainsaw-docker:latest hunt /data/$argv[1] -s sigma/ --mapping mappings/sigma-event-logs-all.yml -r rules/
end
```

```shell
# Execution with alias

chainsaw-hunt EVTX-ATTACK-SAMPLES
```

## References

[https://github.com/WithSecureLabs/chainsaw#searching](https://github.com/WithSecureLabs/chainsaw#searching)

[https://github.com/NextronSystems/valhallaAPI](https://github.com/NextronSystems/valhallaAPI)

[https://github.com/SigmaHQ/sigma](https://github.com/SigmaHQ/sigma)