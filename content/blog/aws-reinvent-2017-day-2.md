+++
title = "AWS re:Invent 2017 Day 2"
date = 2017-11-29T16:44:52+01:00
description = "Here is the recap of my 2nd day at AWS:reInvent 2017"
tags = ["aws", "reinvent"]
draft = false
+++

Here is the recap of my 2nd day at AWS:reInvent 2017. 

Spent the afternoon in the expo area where I had the opportunity to talk to a lot of interesting people from companies like **Hashicorp** (the great guys behind Terraform, Consul and Nomad), **RedHat** (for Ansible), **Confulent** (the company behind Kafka), **vmWare** and their solutions for hybrid cloud and seamless migration), **Github** and **Datadog**. And of course _a lot of swag_!

[Link to Tuesday product announcements](https://aws.amazon.com/new/reinvent/)

## Terry Wise Keynote

_Terry Wise is Vice President, Global Alliances, Ecosystem and Channel at AWS_

_(note: this keynote will be available on Youtube soon - I just focus on what I find the most interesting parts)_

Speakers:

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3006.jpg)

Focus on the markets of:

- IoT, especially in the energy industry
- Serverless architectures
- Financial market: growth in cloud adoption
- Blockchain: interestng example of T-mobile that uses a product from Intel for Identity management based on blockchain
- ML / AI 

#### U.S. Customs and Border Protection

Example of how the US CBP adopted border control biometric analysis using AI with airline partnerships

- incapacity to solve the problem on their own. Partnership with private sector was mandatory.
- Partnership wit airlines Delta, JetBlue to provide link with passenger manifests
- Solution Deployed in JFK

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3011.jpg)

#### AI at AWS

_presented by Matt Woods, GM of AI at AWS_

Machine learning competency: 17 partners identified. 

Challenge is scale **especially on predictions. ** Some customers are experiencing volumes at Hexabyte scale. Interesting case of prediction for IoT at edge layer.

AI is in production and is applied to regulated markets such as medical (note: not all ML solutions at AWS are HIPAA compliant) and financial. 

Some examples:

- Expedia: identify best picture of hotel to increase conversion. 
- tuSimple: Autonomous drive Japanese company
- Neural style transfer for art.
- [Amazon.com](http://amazon.com/) robotics, mapping inventory, targeted AI, echo, Amazon go store in Seattle

Possibility to use [AWS ML solutions labs](https://aws.amazon.com/ml-solutions-lab/): experts from AWS to work with partners to bridge the gap between business expertise and technical implementation.

#### Other notes

AWS certification is critical for growth (50x factor) - because they are looking for specialized people for production scale projects.

Networking competency with 18 partners.

Interesting slide on potential and growth of both Software spending and Cloud workloads:

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3025.jpg)

#### Pacific Gas and Electric Company

Example of PG&E is adopting the cloud, with objective to have 0 datacenters. Cloud is enabler for exponential growth - and fosters exponential thinking, which is necessary for disruption. Technical limits are lifted with cloud adoption - much more difficult to achieve with owned DCs.

Mentorship program for cloud adoption by using a Cloud Center of Excellence - while extending AWS certification programs to non-IT teams

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3020.jpg)

Objective: to certify 10% of the employees _(note: according to wikipedia, PG&E has 20k employees)_

Cloud eliminates structural costs, because:

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3021.jpg)

#### Siemens & MindSphere

Siemens announced the availability of an open platform to manage industrial IoT, based on Siemens experience - [MindSphere](https://www.siemens.com/global/en/home/products/software/mindsphere.html)

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3027.jpg)

#### Andy Jassy closing notes

Market opportunities

1. market of DB migration from legacy system. Focus on Oracle migrations (legacy vs customer happiness) - _(personal note: Amazon.com was a large Oracle customer - to migrate out AWS developed DynamoDB)_.
2. ML area. Tools too complicated. Democratize tools and make them accessible
3. IoT and connected devices. Fastest adoption compared to ML and DevoOps waves



## Where do all data streams go? Building a data lake on AWS

_Note: this was a chalk-talk: most of the discussion happened as a Q&A format!_

Datalake as complementary to data warehouse.

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3031.jpg)

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3032.jpg)

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3034.jpg)

S3 as a data collection system, because low cost and can scale infinitely. Data lake requires normalization and processing (data swamp risk). Data classification can be performed as a trigger with lambda functions on the data flow (metadata tagging on dynamodb or ES). Different form batch processing that does intelligence on the data (emr, glue - which is based on pyspark).

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3035.jpg)

Athena allows not to have tools or query data - take a peek at data, but not to use it as an OLTP tool. Quicksight to read data from multiple sources (tableau like).

Lambda approach: speed and batch stream. As an example, an Ad recommendation system uses the speed processing against batch processed data.

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3036.jpg)

**Catalog and search**: difficult to achieve at scale to catalog all the data coming in.

Security:

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3037.jpg)

Seed [datalake CloudFormation template available here](http://docs.aws.amazon.com/solutions/latest/data-lake-solution/template.html) to kick the tires. 



## Developing and deployment at the speed of light: automating serverless deployments

_Note: this was a chalk-talk: most of the discussion happened as a Q&A format!_

Brief lambda introduction _([I wrote about it too!](https://blog.mywebofthings.com/blog/going-serverless-with-spring-cloud-function/))_

Example of CI/CD with AWS Code Pipelines. The example CloudFormation template can be found [here](https://s3-us-west-2.amazonaws.com/gpsct308/README.txt).

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3045.jpg)

AWS CodePipeline supports integrations with:

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3043.jpg) 

Other notes:

- Use aliases on Lambda to achieve blue/green deployments, so that the callers do not need to be modified.
- Step function to connect multiple lambda calls.
- Parameter store for configuration

Takeaways:

![aws reinvent day2 slide](/img/aws-reinvent-2017/day2/IMG_3047.jpg)

([AWS SAM](https://github.com/awslabs/serverless-application-model) is an open source application model that extends CloudFormation format, and adopts a _convention over configuration_ strategy to reduce template verboseness)