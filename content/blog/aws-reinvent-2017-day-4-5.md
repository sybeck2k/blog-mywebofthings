---
title: AWS re:Invent 2017 Day 4 and 5
date: 2017-12-01T20:44:52+01:00
description: Recap of my 4th and 5th day at AWS:reInvent 2017
tags: ["aws", "reinvent"]
draft: false
typora-root-url: ../../static
---

This is the last series of my notes on the conferences/keynotes/workshops I've joined at re:Invent 2017. I've condensate 4th and 5th day as Friday was _only_ the morning.... whoa what a week!

[Link to Friday product announcements](https://aws.amazon.com/new/reinvent/)

## Werner Vogels’ keynote

_[Youtube video](https://www.youtube.com/watch?v=nFKVzEAm-ts) - and as I don't want to write everything, here are what I think are the most interesting parts of 3 hours of presentations_

The 4 commandments of 21st century cloud architectures:

- Controllable
- Resilient
- Adaptive
- Data driven (don’t guess - measure and improve)

Collaborative: AWS proposes architecture references, tools and recommendations based on feedback from the customers. Launch of minimal feature sets to solve a problem, and iterate on customers feedback (example dynamodb an provisioned iops feature).

Cloud removed infrastructure barriers. *Data became the way that business works*.

- Iot is a consequence: collect more data and interact with the real world
- P3 instances to allow real-time (online) neural network training, improvement in software
- Interfaces will be human centric - not machine centric. Voice is the beginning.

IRRI example. Digital system to fertilize the lands:users call a phone number , describe, amend get instructions. 90% reduction in fertilizer usage

Backends designs will need to change to respond to more human behaviors, and natural interfaces (such as Alexa).

Concept of planes

- Admin plane
- Control plane
- Data plane

Iflix example. Real architectures are complex. That’s where the AWS well architected framework come in. To provide help to design large architectures leveraging AWS.

![IMG_3083](/img/aws-reinvent-2017/day4/IMG_3083.jpg)

Security is #1 priority, first investment area for AWS. encrypt at rest and in transit. KMS with byok or AWS managed. **“Security is everyone job, everyone is a security engineer”**. Integration of security in CICD pipelines, to prevent, and analyze actively all changes to critical services (IAM, Cloudtrail, DBs...). Automation tools. AWS config rules to create snapshots of the architecture and track evolutions in architecture.

AWS cloud9 code IDE announcement. (Bought by Amazon in 2016 <https://techcrunch.com/2016/07/14/amazons-aws-buys-cloud9-to-add-more-development-tools-to-its-web-services-stack/>)

Focus on availability and resilience. Exponential fallback and short circuiting to prevent overloading of already overloaded systems.

5 9s availability not possible with one region. Possible with multi region. Difficult to achieve due to replication over regions complexity (latency and multi-master problem), but improving using multi region replication such as dynamodb new capability.

Slide on reliability from well [architected framework](https://aws.amazon.com/architecture/well-architected/) - and long focus on it

Test reliability by causing faults to systems. Netflix example with chaos team. **What happens *if* it fails to what happens *when* it fails**. ([free eBook](http://www.oreilly.com/webops-perf/free/chaos-engineering.csp)). [ChAP](https://medium.com/netflix-techblog/chap-chaos-automation-platform): Chaos Automation platform.

Focus on microservices, enabled by container.

- ECS
- EKS
- Fargate

*(Note: Comparison of the 3: https://sysdig.com/blog/ecs-fargate-eks-kubernetes-aws-compared)*

API gateway VPC integration announcement

Digitalgloble examples _(I really recommend to check the video of the presentation of this company, it's  impressive to say the least)_. [Digitalglobe.com/reinvent](http://digitalglobe.com/reinvent)

- AWS sage maker for AI to reduce cache misses
- Gbdx notebooks.
- Geoscape- example for 5g deployment to identify trees and better plan networking deployment.

AI focus with [Deeplens](https://aws.amazon.com/deeplens/) - presentation with Intel





## The AWS cloud value framework

The AWS Cloud Value Framework is based on 4 pillars

- TCO
- Resource efficiency
- Operational resilience
- Business agility

![IMG_3095](/img/aws-reinvent-2017/day4/IMG_3095.jpg)

Examples from businesses. **Business agility is actually the biggest gain in cloud adoption**.

Calculation based on monetary value, but can use KPIs as well (and then apply a value to KPI, whenever possible).

### TCO

- include server, facilities, network + facilities
- Example of calculation for instance c4.4xl with labor, software, rack and labor, 3y is 28.4k on premises vs 10k on AWS (assumes 3y reserved). Prorate it if already provisioned. Generates a cash flow over the period

### Business agility

Base on a KPI. Either adjust to dollar value, or do a comparison over time. Include CCoE costs with a kick off team and training to achieve the speed.

![IMG_3097](/img/aws-reinvent-2017/day4/IMG_3097.jpg)

### Operational resilience

Costs of downtime factored by cost category. For example, cost of labor x downtime of a production system. Focus on major areas of cost to find largest impact of downtime.

### Resource efficiency

Example of resource efficiency on a server admin. Process to build a business case.

![IMG_3098](/img/aws-reinvent-2017/day4/IMG_3101.jpg)

Useful resources:

- [AWS TCO Calculator](https://aws.amazon.com/tco-calculator/)
- [Cloud Economics Center](https://aws.amazon.com/economics/)
- [Case Studies](https://aws.amazon.com/solutions/case-studies/all/)





## Leveraging the AWS Cloud Adoption Framework to build your cloud Action Plan

_Another hands-on session - but no laptops! just post-it and people! - where the objective is to build a Cloud Adoption Plan based on the [CAF](https://aws.amazon.com/professional-services/CAF/)_

![IMG_3109](/img/aws-reinvent-2017/day4/IMG_3109.jpg)



## Integrate Alexa into your product using the AVS Device SDK

_...and yes, another workshop! We left the room with an Alexa-enabled Raspberry-Pi! Based on the AVS device SDK. We've basically followed [this tutorial](https://github.com/alexa/avs-device-sdk/wiki/Raspberry-Pi-Quick-Start-Guide), with many interesting details on the inner works of the SDK. If you want to play with it, I recommend to pick a decent microphone, because depending on your HW the capability to recognize the trigger word (Hey Alexa!) could be quite limited)_

![IMG_3134](/img/aws-reinvent-2017/day5/IMG_3134.jpg)

![IMG_3138](/img/aws-reinvent-2017/day5/IMG_3138.jpg)





## Big data, analytics and machine learning on AWS lambda

Serverless natural match to big data as you pay per volume.

- Kinesis integration with lambda for streaming.
- Batch processing based on s3 triggers.
- Periodic triggers to do processing at bursts. Uses sqs to provide volume flow normalization
- MapReduce with lambda: aggregations and computation on data. See [awslabs lambda reference mapreduce](https://github.com/awslabs/lambda-refarch-mapreduce). Integration with *S3 Select* to increase performance by selective selection of data from buckets. Note that lambda execution time is limited and mostly single core, so EMR has its application space for larger aggregations phases.

![IMG_3138](/img/aws-reinvent-2017/day5/IMG_3138.jpg)

Lambda analytics with lambda. Example of LambdaStats for investigating and reduce clod starts of lambda execution. Aggregates data from logs locally on EC2, and pushes them to kinesis. Developed in 2 days, less than 100 lines of python. But required fixes to adjust: sharding was necessary at aggregation and caching level (see picture below, peaks are caused by data loss at metrics ingestion level).

![IMG_3143](/img/aws-reinvent-2017/day5/IMG_3143.jpg)

![IMG_3144](/img/aws-reinvent-2017/day5/IMG_3144.jpg)

Example of Lambda Tuning Pipeline. Objective to optimize coldstart events. Integrates data from LambdaStats, and together with it provides an analytics platform, completly serverless. But since objective is to optimize scheduler for lambda, it was not recommended to use the scheduler on lambda, but rather on EC2

#### Machine learning inference

Training data can be processed on emr, tensorflow... . But inference can be performed with lambda.

Example of using API gateway to do inference via API call agains lamdda and a trained model.

Example of anticipating load to provision extra sandboxes for customer, according to a ML model built on historical data. That’s integrated with the previous pipelines, and augments the collected data.