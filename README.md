# AMI: Base Ubuntu

A Packer template for creating a base image other services can build on top of. Based on Canonical's Ubuntu 18.04 image.

## Services

The following services are set up on the base image.

### Consul

**Note: Before use, the Consul agent requires configuration.**

The agent from Hashicorp's [Consul][consul] service is configured to run on any instance launced from this AMI.

#### Configuration

Before use, the Consul agent needs to know which Consul cluster to join. The configuration specifying the cluster should be placed in a new file in the `/opt/consul/config` directory. 

If you add this configuration after the instance boots or through a user data script, make sure to restart the service.

```bash
sudo systemctl restart consul.service
```

### Vault

Hashicorp's [Vault][vault] is installed. No configuration is provided.

## Deployment with CodeBuild

This repository is configured to be built with AWS CodeBuild. The CodeBuild project must be manually configured to be triggered when changes are pushed to GitHub. In order to save the AMI that is produced, the CodeBuild instance must have the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CopyImage",
                "ec2:CreateImage",
                "ec2:CreateKeypair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteKeyPair",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteVolume",
                "ec2:DeregisterImage",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "ec2:GetPasswordData",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:RegisterImage",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances"
            ],
            "Resource": "*"
        }
    ]
}
```


## Building the AMI

Before building, you must have the following prerequisites:
* [Packer][packer] downloaded and placed somewhere on your `$PATH`.
* A valid set of AWS credentials configured. These can be specified as environment variables or placed in `~/.aws/credentials`. The credentials must at least authorize the user to manipulate key pairs, security groups, EC2 instances, and AMIs.

You may then validate the template and build the AMI.

```
packer validate ubuntu-packer-template.json
packer build ubuntu-packer-template.json
```

## License

This projects is licensed under the [MIT License](LICENSE).


[consul]: https://www.consul.io/
[packer]: https://www.packer.io/
[vault]: https://www.vaultproject.io/
