+++
date = "2017-06-25T20:30:26+02:00"
title = "Lauching your first job with Hasicorp's Nomad"
draft = true
+++

In this article we will deploy a few (Nomad)[https://nomadproject.io/] jobs on a small dual-DC cluster. In the (previous blog article)[https://blog.mywebofthings.com/blog/getting-started-with-hashicorp-nomad/] you can find a walkthrough and a Terraform script to deploy the cluster. The following examples are based on the architecture schema of the previous article.

We will submit _jobs_ to the Nomad servers directly from our local instance. To do so, we will need to have a Nomad client installed locally and access to the Nomad server on port 4646.

A Nomad job is described in HCL ((Hashicorp's config definition format)[https://github.com/hashicorp/hcl]). Let's generate an example job with `nomad init`. This will generate an example, documented job to execute a Docker based Redis service. Let's just submit the job as-is and see what happens.

    $ nomad run -address=$() example.nomad 


The job is submitted, but the scheduler will not find any matching instance of the cluster to run the job. Why? Well...

    # The "datacenters" parameter specifies the list of datacenters which should
    # be considered when placing this task. This must be provided.
      datacenters = ["dc1"]

But our cluster has 2 datacenters, called `eu-west-1a` and `eu-west-1b`. Let's fix that by allowing this job to run on any of the 2 DCs.

    $ nomad run -address=$() example.nomad



