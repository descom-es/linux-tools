# linux-tools

Tools develop by [Descom.es](https://www.descom.es) to adminitration Linux Systems.

## Scripts

* [have_upgrades.sh](/scripts/have_upgrades.sh); you can get the num of upgrades
pending to install in SO

```bash
aws ssm send-command --document-name "AWS-RunRemoteScript" --instance-ids "****" --parameters '{"sourceType":["GitHub"],"sourceInfo":["{\"owner\": \"descom-es\",\"repository\": \"linux-tools\",\"path\": \"/scripts/have_upgrades.sh\"}"],"executionTimeout":["3600"],"commandLine":["have_upgrades.sh"]}' --timeout-seconds 600 --region eu-west-1

aws ssm send-command --document-name "AWS-RunShellScript" --targets "Key=instanceids,Values=***" --parameters '{"workingDirectory":[""],"executionTimeout":["3600"],"commands":["yum -y update"]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --region eu-west-1
```


## MySQL

```bash
aws ssm send-command --document-name "AWS-RunRemoteScript" --instance-ids "****" --parameters '{"sourceType":["GitHub"],"sourceInfo":["{\"owner\": \"descom-es\",\"repository\": \"linux-tools\",\"path\": \"/mysql\"}"],"executionTimeout":["3600"],"commandLine":["bin/install.sh"]}' --timeout-seconds 600 --region eu-central-1
```
