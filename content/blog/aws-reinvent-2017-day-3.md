---
title: AWS re:Invent 2017 Day 3
date: 2017-11-30T01:44:52+01:00
description: Recap of my 3rd day at AWS:reInvent 2017
tags: ["aws", "reinvent"]
draft: false
typora-root-url: ../../static
---

This one is shorter - I missed Andy Jassy keynote as I preferred to prioritize Werner Vogels' one of tomorrow.... but no worries it's on [Youtube](https://www.youtube.com/watch?v=1IxDLeFQKPk)!

[Link to Thursday product announcements](https://aws.amazon.com/new/reinvent/)

## Using AWS CloudTrail Logs for scalable, automated anomaly detection

_This was a workshop, where we built the anomaly detection system (a basic one) using Lambda and Cloudtrail - [code is on Github!](https://github.com/aws-samples/aws-cloudtrail-analyzer-workshop)_

![IMG_3055](/img/aws-reinvent-2017/day3/IMG_3055.jpg)

## How Amazon Business Uses Amazon Cloud Directory as the Data Store for Its Account Management Platform

Comparison of relational, Nosql, graph and hierarchical.

Focus on solving hierarchical data stores. Difficult to use classical solution because they are not designed to be scalable and not optimized, schemas are fixed and difficult to mutate.

![IMG_3060](/img/aws-reinvent-2017/day3/IMG_3060.jpg)

AWS cloud directory developed to cover for those issues.

![IMG_3056](/img/aws-reinvent-2017/day3/IMG_3056.jpg)

Cognito is built on cloud directory.

Supports CloudTrail and policy hierarchies . The trees are built using facets that define the relationship types.

![IMG_3061](/img/aws-reinvent-2017/day3/IMG_3061.jpg)

Amazon business use case - a marketplace dedicated for companies - 1bln in volume in US alone. Modeling a company is different from individual consumers: more complicated policies, workflows and different structures to handle. nosql not viable, neither graph database. in cloud directory, data is just referenced by weak links (references) to the authoritative source.

LDAP/AD integration is in the roadmap for federated authorization.

Example [code on Github](https://github.com/aws-samples/amazon-cloud-directory-sample)

## Another day, another billion flows

VPC fully code based. Overlay on physical layer. Introduction of VPC features and capabilities. New support for inter-region VPC peering. (_the speaker referenced [Nitro architecture](https://www.theregister.co.uk/2017/11/29/aws_reveals_nitro_architecture_bare_metal_ec2_guard_duty_security_tool/) that was also announced today_)

VPC required custom encapsulation protocols because **classical Overlay, MPLS, VXLAN** do not work at scale.

Blackfoot edge devices are used to connect a VPC to the external systems, acting as a NAT gateway that can understand the encapsulation protocol.

![IMG_3065](/img/aws-reinvent-2017/day3/IMG_3065.jpg)

![IMG_3063](/img/aws-reinvent-2017/day3/IMG_3063.jpg)

The virtual router (purple round) rely on a mapping service to know the routing patterns, and includes routing configurations. Requires caching and heavy optimization between routers and mapping service (microsecond scale).

Flows are subsequent packets associated to the same ENI, or SG (because they are stateful), NAT gateways connections... and they are logged and auditable (table of source ip/port and destination up/port and protocol). Stateful inspection of packets to prevent spoofing for multiple protocols (tcp, udp, icmp).

![IMG_3067](/img/aws-reinvent-2017/day3/IMG_3067.jpg)

![IMG_3068](/img/aws-reinvent-2017/day3/IMG_3068.jpg)

Hyperplane: at VPC level. Runs on EC2, just increased authorization - to implement Nat gw, elbs, network elbs.... requires distributed consensus to agree on distributed states of packets. Applies port randomization to bypass risks for software vulnerabilities to packets spoofing.

For security, hyperplane works at flows level, isolated from VPC mappings.

Hyperplane nodes are multitennant - but needs to handle QOS and security. Hyperplane snode scale to terabit scales. Uses **shuffle sharding** to protect from noisy neighbors. benefits from distributed execution to minimize risks of interference in performance. (below probability of shard overlapping when using random shuffling over 100 hyperplane nodes)

![IMG_3070](/img/aws-reinvent-2017/day3/IMG_3070.jpg)

Privatelink service is enabled by hyperlink.

![IMG_3071](/img/aws-reinvent-2017/day3/IMG_3071.jpg)