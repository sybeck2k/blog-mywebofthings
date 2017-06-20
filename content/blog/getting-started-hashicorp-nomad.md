+++
date = "2017-06-17T22:05:33+02:00"
title = "Getting started with Hashicorp Nomad"
description = "Nomad scheduler provides enterprise-class services, while remaining simple to deploy and operate"
draft = true
+++

For a recent project, I was exploring around for different ways of deploying a microservice oriented application 
at ease and at scale, but without clutter and messy configurations. I've already used Docker Swarm mode to achieve this, 
and I know about Mesos and Kubernetes, but it felt they are overkill for my context of coordinating less than 20 services.

Excluding some new exoteric projects, I stumbled upon [Hashicorp's Nomad](https://www.nomadproject.io/), which claims to be `A Distributed, Highly Available, Datacenter-Aware Scheduler`. What interested me the most waws the _Datacenter-Aware_ part, plus I'm a huge fan of Hashicorp's solutions such as Consul (you can read 
a [previous article about it](https://blog.mywebofthings.com/blog/deploying-a-highly-available-dual-az-consul-cluster-on-aws/)), Terraform (a multi-cloud IaaS tool), and Vagrant.

Nomad's Architecture
------


In terms of architecture, Nomad is based on a number of servers, of which only 0 or 1 of them is a leader at any given time through 
leader election using Raft consensus protocol, which connect to agent to know their status, and to submit _jobs_. A job is a workload that is composed of _tasks_, that is described in JSON or HCL format, and submitted via a REST API to the server by the end user. In a way, it's a smaller subset of a Swarm functionalities. The key advantage compared to Swarm though, is that Nomad uses a concept of _driver_ to abstract the method of execution of tasks. This makes Nomad **exetremly powerful and extensible**, because as a consequence it can run on heterogeneous clusters (you can mix a cluster of ARM, Windows, Unix...). Examples of currently supported drivers are Docker, Java, chroot, LXC, raw executables.
If you want a deep dive, you can read more about [Nomad architecture here](https://www.nomadproject.io/docs/internals/architecture.html).

Enough talking...let's get started.

Deploying Nomad
------

For this example, we will deploy using Terraform on AWS. Here is the target architecture:
![Consul Dual AZ](/img/consul-ha/consul-cluster-dual-AZ.png)

As you can see, it's similar from the previous post, as we will use [Consul to bootstrap the Nomad cluster](https://www.nomadproject.io/docs/service-discovery/index.html) and for service discovery. There are a few things to explain:

* **The Nomad cluster is NOT higly-available**, as we deploy only 2 servers. This allows to experiment later when simulating loss scenarios.
* The Nomad servers are not clients. As receommended in the Nomad documentation, it is better to separate the Job dispatching machines from the agents. In case of large deployments, the servers will consume networking and CPU - which might in turn impact business application performance. 
* The Nomad servers are identified as belonging to different AZs.

Moreover, I'm using the Nomad server cluster as a "bastion" area. This is the most recommended AWS security configuration. Basically, the bastions are the servers that you can connect to, and they are the only way to access the other instances of the cluster through SSH. You can read more about it on the [AWS official documentation](http://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html). As a consequence, you cannot directly SSH into the business application instances.

The Terraform script is available on [Github]() and it will do all the configuration automatically. It will install the Nomad agent in the business application instances layer, and the Nomad servers in the bastions. You can go through the user-data scripts included in the repository for more details about the process (it relies mostly on querying the EC2 API to discover instances and set-up configuration files). (_Note to self: the scripts need really some rework..._)

Since we use Consul to bootstrap the Nomad cluster, the configuration files are very simple. For instance, the server configuration looks like this:

	{
	  "data_dir" : "/opt/nomad",
	  "name"     : "$INSTANCE_ID",
	  "datacenter"  : "$AZ",
	  "server": {
	    "enabled"       : true,
	    "bootstrap_expect" : 2,
	    "retry_join" : [
	      "<OTHER-AZ-IP1>"
	    ]
	  }
	}


And Nomad clients:

	{
	  "data_dir" : "/opt/nomad",
	  "name"     : "$INSTANCE_ID",
	  "datacenter"  : "$AZ",
	  "client": {
	    "enabled"       : true,
	    "network_speed" : 100,
	    "options"       : {
	      "driver.raw_exec.enable": true
	    },
	    "servers" : [
	      "<SERVER_IP1>", "<SERVER_IP2>"
	    ]
	  }
	}


Verifying the Nomad cluster health
------

We can now check that the Nomad is up and running. To do so, we can just check the logs on CloudWatch (yes, also Nomad logs are centralized):

_Nomad cloudwatch img_

To confirm this, let's connect to one of the bastion hosts:

_connect SSH_
_show Nomad status_

So, we now have a job scheduler (Nomad) and a highly-available service-discovery backbone (Consul). In the next blog article I'll show you how to execute tasks on our new cluster, and then we will try to break some things up and see how Nomad reacts: there are plenty of questions that can be answered only through experimentation (or going through the source code :p!).