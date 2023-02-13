# Cdk-Stage

## Summary
Rapidly deploys a cdk project that implements stages, an environment construct, and regional configurations. This follows a pattern suitable for managing multi-account deployments for users that already utilize AWS Organizations. It utilizes stack inheritance to limit code duplication and centralize configuration of each stage.

## Project Structure
Projects generated with cdk-stage are created by first executing `cdk init --app language=typescript` and then utilizing the templates and directories included to alter the structure. Detailed READMEs are included with the templates and copied into each of the directories.



## Stages
