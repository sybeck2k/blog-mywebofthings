+++
date = "2017-06-25T20:30:26+02:00"
title = "Launching your first job with Hasicorp's Nomad"
tags = ["aws", "consul", "nomad"]
draft = false
+++

In this article we will deploy a few [Nomad](https://nomadproject.io/) jobs on a small dual-DC cluster. In the [previous blog article](https://blog.mywebofthings.com/blog/getting-started-with-hashicorp-nomad/) you can find a walkthrough and a Terraform script to deploy the cluster. The following examples are based on the architecture schema of the previous article.

We will submit _jobs_ to the Nomad servers directly from our local instance. To do so, we will need to have a Nomad client installed locally and access to the Nomad server on port 4646.

A Nomad job is described in HCL ([Hashicorp's config definition format](https://github.com/hashicorp/hcl)). Let's generate an example job with `nomad init`. This will generate an example, documented job to execute a Docker based Redis service. Let's `plan` the job and see what would happen:

~~~sh
$ nomad plan example.nomad
+ Job: "example"
+ + Task Group: "cache" (1 create)
+   + Task: "redis" (forces create)

Scheduler dry-run:
- WARNING: Failed to place all allocations.
-   Task Group "cache" (failed to place 1 allocation):
-       * No nodes were eligible for evaluation
-           * No nodes are available in datacenter "dc1"
~~~

The scheduler did not find any matching instance of the cluster to run the job, as the job is configured by default to run on `dc1`, but our cluster has 2 datacenters, called `eu-west-1a` and `eu-west-1b`. Let's fix that by allowing this job to run on any of the 2 DCs, and run it.

    $ nomad plan example.nomad
    + Job: "example"
		+ Task Group: "cache" (1 create)
  		+ Task: "redis" (forces create)

		Scheduler dry-run:
		- All tasks successfully allocated.

		Job Modify Index: 0
		To submit the job with version verification run:

		nomad run -check-index 0 example.nomad

    $ nomad run -check-index 0 example.nomad

    ==> Monitoring evaluation "72e0e5ea"
    		Evaluation triggered by job "example"
    		Allocation "8dd4be51" created: node "ec28626d", group "cache"
    		Evaluation status changed: "pending" -> "complete"
    ==> Evaluation "72e0e5ea" finished with status "complete"

We can check where the job is actually being executed by checking its status:

    $ nomad status example
    ID            = example
    Name          = example
    Type          = service
    Priority      = 50
    Datacenters   = eu-west-1a,eu-west-1b
    Status        = running
    Periodic      = false
    Parameterized = false

    Summary
    Task Group  Queued  Starting  Running  Failed  Complete  Lost
    cache       0       0         1        0       0         0

    Allocations
    ID        Eval ID   Node ID   Task Group  Desired  Status   Created At
    8dd4be51  72e0e5ea  ec28626d  cache       run      running  06/28/17 09:07:11 CEST

You can match easily the node ID with the instance ID by running `nomad node-status`. You can connect to it (remember that you will have to go through the bastion :) ), and verify that there is a Docker container running:

~~~sh
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                    NAMES
5f5525256ddc        4e482b286430        "docker-entrypoint..."   10 minutes ago      Up 10 minutes       10.0.2.147:22655->6379/tcp, 10.0.2.147:22655->6379/udp   redis-8dd4be51-d9c2-fd55-a1ff-7ba8d777484c
~~~

There are a few important things to notice here:

  * The docker image used to launch the container is the image ID and not the tag that is found at evaluation time.
  * The ports are redirected to some system-available ports. The ports are selected by Nomad - and not Docker (and this is important)

If we inspect the container, we can see more interesting facts. Let's focus first on performance constraints:

    $ docker inspect -f '{{ .HostConfig.CpuShares }}' 5f5525256ddc
    500
    $ docker inspect -f '{{ .HostConfig.Memory }}' 5f5525256ddc
    268435456

Nomad translated the job configuration into [Docker resource constraints](https://docs.docker.com/engine/admin/resource_constraints/#cpu). Here is the relevant job configuration:

    resources {
     cpu    = 500 # 500 MHz
     memory = 256 # 256MB
     network {
       mbits = 10
       port "db" {}
     }
    }

The `500 Mhz` comment is not entirely correct - at least not in the Docker case. The CPU limit is applied in terms of _CPU shares_, where the maximum is 1024 and the minimum is 0. Docker documentation on the argument is very clear:

> Set this flag to a value greater or less than the default of 1024 to increase or reduce the container’s weight, and give it access to a greater or lesser proportion of the host machine’s CPU cycles. This is only enforced when CPU cycles are constrained. When plenty of CPU cycles are available, all containers use as much CPU as they need. In that way, this is a soft limit

Nomad added also a series of environment variables to the container:

    $ docker inspect -f '{{ .Config.Env }}' 5f5525256ddc
    [NOMAD_HOST_PORT_db=22655 NOMAD_TASK_DIR=/local NOMAD_ALLOC_ID=8dd4be51-d9c2-fd55-a1ff-7ba8d777484c NOMAD_TASK_NAME=redis ... ]

As mentioned above, Nomad identified the published port _before_ the execution of the container. This allows for the execution context of the container to know its external port. This is very useful for some applications that need to propagate some information about themselves to the others. In general, this problem is widely known and discussed by the Docker community (see (docker introspection)[https://www.google.com/search?q=docker+introspection] on Google).

Now that we know more about the job instance itself, let's scale up things a bit. We will ask Nomad to deploy 15 instances of the job. To do so, update the `count` parameter in the file `example.nomad`.

		nomad plan example.nomad
		+/- Job: "example"
		+/- Task Group: "cache" (14 create, 1 in-place update)
		  +/- Count: "1" => "15" (forces create)
		  +/- Task: "redis" (forces in-place update)

		Scheduler dry-run:
		- All tasks successfully allocated.

		Job Modify Index: 56
		To submit the job with version verification run:

		nomad run -check-index 56 example.nomad    

Since we have 11 instances on the cluster, and we use a dual-AZ DC job, we have some instances running multiple times the same service. The easiest way to see at once all the service instances, we can check Consul. If you remember, we configured our cluster to work together with Consul for Service registration and discovery. We can use the REST API of Consul to do so, by using `curl` from any instance of the cluster:

    $ curl localhost:8500/v1/catalog/services?pretty
    {
      "consul": [],
    	"global-redis-check": [
      	"global",
        "cache"
      ],
    	"nomad": [
        "http",
        "rpc",
        "serf"
      ],
      "nomad-client": [
        "http"
    	]
    }

The Nomad job registered our task as `global-redis-check`. To see the actual instances, we can just:

    $ curl localhost:8500/v1/catalog/service/global-redis-check?pretty
    [
      {
        "ID": "674bd115-07b4-cfd7-5270-c8bc1ce94bef",
        "Node": "i-00954d5b57fdf7a4f",
        "Address": "10.0.2.117",
        "Datacenter": "eu-west-1a",
        "TaggedAddresses": {
            "lan": "10.0.2.117",
            "wan": "10.0.2.117"
        },
        "NodeMeta": {},
        "ServiceID": "_nomad-executor-add6f2f5-4e51-20ca-9d45-8b3876c0b349-redis-global-redis-check-global-cache",
        "ServiceName": "global-redis-check",
        "ServiceTags": [
            "global",
            "cache"
        ],
        "ServiceAddress": "10.0.2.117",
        "ServicePort": 25966,
        "ServiceEnableTagOverride": false,
        "CreateIndex": 1995,
        "ModifyIndex": 1995
      },...
    ]

At this point, it's easy to have any application inquiring the Consul API to get the list of the services, and where to find them. Remember that we have actually a dual-DC cluster: Consul by default will list only the instances belonging to the same DC as the local agent.

We now go on and try to push the system further. Why not launch 50 instances of the job?

		$ nomad plan example.nomad
		+/- Job: "example"
		+/- Task Group: "cache" (35 create, 15 in-place update)
		  +/- Count: "15" => "50" (forces create)
		      Task: "redis"

		Scheduler dry-run:
		- WARNING: Failed to place all allocations.
		  Task Group "cache" (failed to place 17 allocations):
		    * Resources exhausted on 11 nodes
		    * Dimension "memory exhausted" exhausted on 11 nodes

Nomad is preventing us to fall into memory starvation: with the current configuration we would be able to run no more than 30 instances.

If we stop a Docker container, Nomad will rapidly re-launch a replacing instance, to achieve the instance count that we set in the job description.

That's all for now - but in the next article we'll see more of Nomad, and some features such as node-drain and driver failures.
