+++
date = "2017-06-10T16:53:02+02:00"
tags = ["aws", "consul", "high-availability"]
title = "Deploying a highly available, dual AZ Consul cluster on AWS"
draft = true
+++

Deploying an highly available Consul cluster on AWS seems to be quite straightforward. There is also a [CloudFormation template](https://aws.amazon.com/quickstart/architecture/consul/) available from the AWS team. The only issue is that the reference architecture requires 3 Availability Zones.

What about deploying on a dual-AZ? That might be the only option in some zones such as Frankfurt, Sydney or Tokyo.
We will show how to leverage the WAN Gossip pool to isolate the AZs failure zones.
At the end of the article, you will have a resiliant Consul cluster that can sustain the loss of up to 1 server, or 1 entire AZ.
<!--more-->

So, why do we use WAN peering? From [Consul documentation](https://www.consul.io/docs/guides/datacenters.html):

> One of the key features of Consul is its support for multiple datacenters. The architecture of Consul is designed to promote a low coupling of datacenters so that connectivity issues or failure of any datacenter does not impact the availability of Consul in other datacenters. This means each datacenter runs independently, each having a dedicated group of servers and a private LAN gossip pool.

In other words, we will map one Availability Zone to 1 Datacenter.

Here is an architecture diagram of what we will deploy:
![Consul Dual AZ](/img/consul-ha/consul-cluster-dual-AZ.png)

To deploy the solution, we'll use [Terraform](https://www.terraform.io/), the code is available on [Github](), and it's a fork of the original article '[Creating a Resilient Consul Cluster for Docker Microservice Discovery with Terraform and AWS](http://www.dwmkerr.com/creating-a-resilient-consul-cluster-for-docker-microservice-discovery-with-terraform-and-aws/)'.

In short, here is what the Terraform code does:

1. Create a VPC in the region
2. Configure the internet gateway and egress rules
3. Create 2 subnets, one per each AZ
4. Prepare security groups (we will use instance tags to bootstrap the cluster and configure the nodes)
4. Prepare 2 Launch Configuration, 1 for the Consul Servers 1 for the Consul Clients
5. Associate 2 Autoscaling Groups to the Consul Server launch configuration (1 per AZ), with size of 3
6. Associate 1 Autoscaling Group to the Consul client launch configuration (spanning the 2 AZs), with size of 5

The user-script used to initialize the EC2 instances has some bonus features:

* Send Consul and syslog messages to CloudWatch Logs for centralization
* Configure local DNS resolving to use Consul for service discovery

The script should be quite self-explanatory. Once consul is installed, we query the AWS API to find all the matching server instances.
We query for the servers in the same AZ as the requesting node to find the peers belonging to the same AZ. Finally, we look for the servers 
in the _other_ AZ - to use them as WAN peers.

Here is the resulting configuration:

	{
	  "datacenter"  : "$AZ",
	  "node_name"   : "$INSTANCE_ID",
	  "data_dir"    : "/opt/consul",
	  "log_level"   : "INFO",
	  "client_addr" : "0.0.0.0",
	  "bind_addr"   : "$IP",
	  "recursors" : [ "$EC2_NAMESERVER" ],
	  "ports" : {
	    "dns" : 53
	  },
	  "retry_join"  : [
	    "<IP1>", "<IP2>", "<IP3>"
	  ],
	  "retry_join_wan"  : [
	    "<OTHER-AZ-IP1>", "OTHER-AZ-<IP2>", "OTHER-AZ-<IP3>"
	  ],
	  "server"           : true,
	  "bootstrap_expect" : 3
	}

Let's run our Terraform configuration in `eu-west-1`:

<script type="text/javascript" src="https://asciinema.org/a/cr02p6ru3fjndqyojvegyv9jn.js" id="asciicast-cr02p6ru3fjndqyojvegyv9jn" async></script>

Everything good here! Let's try to connect to one instance. We get first all the instances in the first AZ:

    [~]$ INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups --region eu-west-1 --auto-scaling-group-names consul-server-asg-a | jq -r '.AutoScalingGroups | .[].Instances | .[0].InstanceId')'

And we connect to one:
    

    [~]$ CONSUL_SERVER_IP=$(aws ec2 describe-instances --region eu-west-1 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text --instance-ids $INSTANCE_ID)
    [~]$ ssh ec2-user@$CONSUL_SERVER_IP

And let's take a look at the WAN cluster:

    $ consul members -wan
	Node                            Address          Status  Type    Build  Protocol  DC
	i-014851c6e04ab2345.eu-west-1b  10.0.1.175:8302  alive   server  0.8.3  2         eu-west-1b
	i-03a69a2514d74d1ad.eu-west-1b  10.0.1.218:8302  alive   server  0.8.3  2         eu-west-1b
	i-094636fb7bc5e6847.eu-west-1a  10.0.1.8:8302    alive   server  0.8.3  2         eu-west-1a
	i-0b5bf7b0011979a88.eu-west-1a  10.0.1.111:8302  alive   server  0.8.3  2         eu-west-1a
	i-0d44013c06207303c.eu-west-1b  10.0.1.221:8302  alive   server  0.8.3  2         eu-west-1b
	i-0f89b2eb8790d6e54.eu-west-1a  10.0.1.20:8302   alive   server  0.8.3  2         eu-west-1a

There we go - 2 Consul cluster connected to each other. As you can see, the DC name maps to the AZ name.

Let's also try the *DNS interface*:

	$ dig i-0d44013c06207303c.node.eu-west-1b.consul

	; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.62.rc1.55.amzn1 <<>> i-0d44013c06207303c.node.eu-west-1b.consul
	;; global options: +cmd
	;; Got answer:
	;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 40507
	;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

	;; QUESTION SECTION:
	;i-0d44013c06207303c.node.eu-west-1b.consul. IN A

	;; ANSWER SECTION:
	i-0d44013c06207303c.node.eu-west-1b.consul. 0 IN A 10.0.1.221

	;; Query time: 3 msec
	;; SERVER: 10.0.1.8#53(10.0.1.8)
	;; WHEN: Fri Jun  9 14:37:52 2017
	;; MSG SIZE  rcvd: 76


You can try to do the same queries on the other AZ's server. 

If you check CloudWatch Logs, you will find all the consul logs:

![CloudWatch Consul logs](img/consul-ha/cloudwatch-consul-logs.png)

Finally, remember that there *KV stores are isolated*: since each AZ is a possible failure zone, data written in one AZ Consul cluster will not be copied over to the other cluster. You can do so using tools like [Consul Replicate](https://github.com/hashicorp/consul-replicate).

