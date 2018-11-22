# AMI: Base Ubuntu

A Packer template for creating a base image other services can build on top of. Based on Canonical's Ubuntu 18.04 image.

## Services

The following services are set up on the base image.

### Consul

**Note: Before use, the Consul agent requires configuration before it can be run.**

The agent from Hashicorp's [Consul][consul] service is configured to run on any instance launced from this AMI.

#### Configuration

Before use, the Consul agent needs to know which Consul cluster to join. The configuration specifying the cluster should be placed in a new file in the `/opt/consul/config` directory. 

If you add this configuration after the instance boots or through a user data script, make sure to restart the service.

```bash
sudo systemctl restart consul.service
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
